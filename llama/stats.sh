#!/usr/bin/env bash
# stats.sh: the one line a KiSS session writes under Stats: in a pull request,
# the twin of ~/.pi/stats.sh.
#
# A KiSS server keeps its numbers in two files. Its log holds the wall time of
# every answer and every tool it ran, and no clock of its own; the conversation
# holds the tokens, the time of every turn and the time each answer took. So
# the log names the port, the registry names the directory the server runs in,
# and the conversations of that directory that fall in the session make up the
# rest.
#
# usage: stats.sh [<log> | <port> | <conversation.json>] [-v]
#   no argument: the newest log of $KISS_HOME, ~/.kiss by default
#
#   ◷ agent:   the time the model spent answering
#   ⚙ rest:    the time the session spent besides: its span without the agent
#   ↑ in:      prompt tokens, ↓ out: generated tokens, k = 1e3, m = 1e6, floored
#   ≡ msgs:    every entry of the conversations, user, assistant and cli alike
#   ⌨ user:    the entries the user wrote
#
# A time is HH.Hh, MM.Mm or SS.Ss. What no file holds is written as ?, never as
# a zero: a session whose conversations are gone still has its log.

set -eu

# the logs and the registry of the fleet sit beside this script; elsewhere,
# where there is no fleet, $KISS_HOME says where the servers of a machine keep
# them
here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
home=${KISS_HOME:-$here}
verbose=0
arg=

while [[ $# -gt 0 ]]; do
	case $1 in
	-v | --verbose) verbose=1 ;;
	-h | --help)
		sed -n '/^# usage:/,/^# a zero/p' "$0" | sed 's/^# \{0,1\}//'
		exit 1
		;;
	*) [[ -z $arg ]] && arg=$1 ;;
	esac
	shift
done

say() { printf 'stats: %s\n' "$*" >&2; }
die() {
	say "$*"
	exit 1
}

# a span of milliseconds in the units of the line
time_of() {
	local ms=$1 unit=1000 mark=s
	if ((ms >= 3600000)); then
		unit=3600000
		mark=h
	elif ((ms >= 60000)); then
		unit=60000
		mark=m
	fi
	printf '%d.%d%s' $((ms / unit)) $(((ms * 10 / unit) % 10)) "$mark"
}

# a count of tokens, floored to its unit
num_of() {
	local n=$1
	if ((n >= 1000000)); then
		printf '%dm' $((n / 1000000))
	elif ((n >= 1000)); then
		printf '%dk' $((n / 1000))
	else
		printf '%d' "$n"
	fi
}

# the clock a file was last written: a session ends when its server last wrote
last_write() { stat -f %m -- "$1" 2>/dev/null || stat -c %Y -- "$1" 2>/dev/null || date +%s; }

# the clock a file was born, where the system keeps it
first_write() { stat -f %B -- "$1" 2>/dev/null || stat -c %W -- "$1" 2>/dev/null || echo 0; }

# the second a UTC stamp of the registry stands for
to_epoch() {
	date -j -u -f '%Y-%m-%dT%H:%M:%SZ' "$1" +%s 2>/dev/null || date -u -d "$1" +%s 2>/dev/null || echo 0
}

log=
port=
convs=()

if [[ -z $arg ]]; then
	log=$(ls -t "$home"/*.log 2>/dev/null | head -1)
	[[ -n $log ]] || die "no log in $home: nothing to count"
elif [[ -d $arg ]]; then
	log=$(ls -t "$arg"/*.log 2>/dev/null | head -1)
	[[ -n $log ]] || die "no log in $arg"
elif [[ $arg == *.log ]]; then
	log=$arg
elif [[ $arg == *.json ]]; then
	convs+=("$arg")
elif [[ $arg =~ ^[0-9]+$ ]]; then
	port=$arg
	log=$home/$arg.log
else
	die "$arg names no log, no port, no directory and no conversation"
fi

if [[ -n $log && ! -f $log ]]; then
	die "no log at $log"
fi

# the session the log belongs to: the directory its server runs in and the
# second it started, from the line it was recorded with; a port started twice
# has two lines, and the last is the session of that log
port=${port:-${log##*/}}
port=${port%.log}
dir=
since=0
registry=$home/servers.tsv

if [[ -n $port && -f $registry ]]; then
	line=$(awk -F'\t' -v p="$port" '$1 == p { last = $0 } END { print last }' "$registry")
	if [[ -n $line ]]; then
		dir=$(cut -f4 <<<"$line")
		since=$(to_epoch "$(cut -f5 <<<"$line")")
	fi
fi

# the conversations of the session: those whose own span touches its window. A
# conversation resumed across two sessions answers to both, being one
if [[ -z ${convs[0]-} && -n $dir && -d $dir/conversations ]]; then
	end=$(last_write "$log")
	((end > since)) || end=$(date +%s)
	for at in "$dir"/conversations/*.json; do
		[[ -f $at ]] || continue
		jq -es -e --argjson f $((since * 1000)) --argjson t $((end * 1000)) '
      [.[].conversations[]?.entries[]?.time]
      | (. != []) and (. | max) >= $f and (. | min) <= $t
    ' "$at" >/dev/null 2>&1 && convs+=("$at")
	done
fi

# the log: the wall time of every answer of the session, and what it ran
agent=0
calls=0
refused=0
if [[ -n $log ]]; then
	agent=$(sed -nE 's/^\[Agent\] [^ ]+ answered in ([0-9]+) ms$/\1/p' "$log" |
		awk '{ s += $1 } END { print s + 0 }')
	calls=$(grep -cE '^\[Agent\] [^ ]+ calls ' "$log" || echo 0)
	refused=$(grep -cE '^\[HTTP\] Refused ' "$log" || echo 0)
fi

# the conversations: what they cost, how many they hold and when they began and
# ended; the tokens are nowhere but here
tokens=
made=
model=
turns=
user=
first=
last=
if [[ -n ${convs[0]-} ]]; then
	read -r tokens made model turns user first last <<<"$(jq -rs '
    [.[].conversations[]?.entries[]?] as $e
    | [$e[] | select(.role == "assistant")] as $a
    | [ ([$a[].stats.tokens // 0] | add // 0),
        ([$a[].stats.generation // 0] | add // 0),
        ([$a[].stats.system // 0] | add // 0),
        ($e | length),
        ([$e[] | select(.role == "user")] | length),
        ([$e[].time] | min // 0),
        ([$e[].time] | max // 0) ] | map(tostring) | join(" ")
  ' "${convs[@]}")"
fi

# the answers of the conversations cover the conversations, those of the log the
# whole session: the conversations are the work, the log the machine
[[ -n $model && $model != 0 ]] && agent=$model

rest=?
if [[ -n $first && -n $last ]] && ((last > first)); then
	((last - first > agent)) && rest=$(time_of $((last - first - agent))) || rest=0.0s
elif [[ -n $log ]]; then
	start=$(first_write "$log")
	if ((start > 0)); then
		span=$((($(last_write "$log") - start) * 1000))
		((span > agent)) && rest=$(time_of $((span - agent))) || rest=0.0s
	fi
fi

line=(
	"$( [[ -n $agent && $agent != 0 ]] && time_of "$agent" || echo ?)"
	"$rest"
	"$( [[ -n $tokens ]] && num_of "$tokens" || echo ?)"
	"$( [[ -n $made ]] && num_of "$made" || echo ?)"
	"${turns:-?}"
	"${user:-?}"
)

if ((verbose)); then
	say "port   $port"
	say "log    ${log:-none}"
	say "held   ${#convs[@]} conversation(s) in ${dir:-nowhere}: ${convs[*]-}"
	say "calls  $calls run, $refused refused, since $(date -u -r "$since" +%FT%TZ 2>/dev/null || echo ?)"
fi

printf '\xe2\x97\xb7 %s \xc2\xb7 \xe2\x9a\x99 %s \xc2\xb7 \xe2\x86\x91 %s \xc2\xb7 \xe2\x86\x93 %s \xc2\xb7 \xe2\x89\xa1 %s \xc2\xb7 \xe2\x8c\xa8 %s\n' \
	"${line[@]}"

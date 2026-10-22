#!/usr/bin/env bash
# stats.sh: the one line a KiSS session writes under Stats: in a pull request,
# the twin of ~/.pi/stats.sh.
#
# Name it the conversation the session answers in. A server keeps the rest of
# what the line wants in two files: the log of the port it listens on holds the
# wall time of every answer and every tool it ran but carries no clock of its
# own, and the conversation holds the tokens, the time of every turn and the
# time each answer spent generating. The registry names which of the fleet's
# servers holds which conversation, and so which log answers for it.
#
# usage: stats.sh <conversation id> | <conversation.json> | <log> | <port> [-v]
#
#   ◷ agent:   the time the model spent generating, the turns' generation
#   ⚙ tool:    the time the machine spent besides, within those same turns
#   ↑ in:      prompt tokens, ↓ out: generated tokens, k = 1e3, m = 1e6, floored
#   ≡ msgs:    every entry of the conversation, user, assistant and cli alike
#   ⌨ user:    the entries the user wrote
#
# A conversation named by its id or its path counts that conversation alone. A
# log or a port counts the session that log covers: every conversation of that
# server's directory whose own span touches the time the server was up.
#
# A time is HH.Hh, MM.Mm or SS.Ss. What no file holds is written as ?, never as
# a zero: a conversation whose server left no log still has its own numbers.

set -eu

# the logs and the registry of the fleet sit beside this script; elsewhere,
# where there is no fleet, $KISS_HOME says where the servers of a machine keep
# them
here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
home=${KISS_HOME:-$here}
registry=$home/servers.tsv
verbose=0
arg=

while [[ $# -gt 0 ]]; do
	case $1 in
	-v | --verbose) verbose=1 ;;
	-h | --help)
		sed -n '/^# usage:/,/^# a zero/p' "$0" | sed 's/^# \{0,1\}//'
		exit 1
		;;
	-*) printf 'stats: %s is no argument of mine\n' "$1" >&2; exit 1 ;;
	*) [[ -z $arg ]] && arg=$1 ;;
	esac
	shift
done

if [[ -z $arg ]]; then
	sed -n '/^# usage:/,/^# a zero/p' "$0" | sed 's/^# \{0,1\}//' >&2
	exit 1
fi

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

# the clock a file was last written: a session ends where its server last wrote
last_write() { stat -f %m -- "$1" 2>/dev/null || stat -c %Y -- "$1" 2>/dev/null || date +%s; }

# the second a UTC stamp of the registry stands for
to_epoch() {
	date -j -u -f '%Y-%m-%dT%H:%M:%SZ' "$1" +%s 2>/dev/null || date -u -d "$1" +%s 2>/dev/null || echo 0
}

# a line of the registry, the last one written for that port: a port started
# twice has two, and the session of this log is the last of them
line_of() {
	[[ -f $registry ]] || return 0
	awk -F'\t' -v p="$1" '$1 == p { last = $0 } END { print last }' "$registry"
}

# every line of the registry that names a server and the directory it runs in
lines_of() {
	[[ -f $registry ]] || return 0
	awk -F'\t' 'NF >= 5 { print }' "$registry"
}

log=
port=
convs=()

case $arg in
*.log)
	[[ -f $arg ]] || die "no log at $arg"
	log=$arg
	port=${arg##*/}
	port=${port%.log}
	;;
*.json)
	[[ -f $arg ]] || die "no conversation at $arg"
	convs+=("$arg")
	;;
'' | *[!0-9]*)
	# a conversation named by its id belongs to the server whose directory holds
	# it, and the log that answers for it is the log of that server's port
	found=
	while IFS=$'\t' read -r p _ _ where _ where_log _; do
		[[ -f $where/conversations/$arg.json ]] || continue
		convs+=("$where/conversations/$arg.json")
		port=$p
		log=${where_log:-$home/$p.log}
		[[ -f $log ]] || log=$home/$p.log
		[[ -f $log ]] || log=
		found=1 # the last line of that directory, the newest session of it
	done < <(lines_of)
	[[ -n $found ]] || die "$arg names no log, no port, and no conversation of a server in $registry"
	;;
*)
	port=$arg
	log=$home/$arg.log
	[[ -f $log ]] || log=
	[[ -n $log ]] || say "no log of port $port in $home: the conversations alone answer"
	;;
esac

line=$(line_of "$port")
dir=
since=0
if [[ -n $line ]]; then
	dir=$(cut -f4 <<<"$line")
	since=$(to_epoch "$(cut -f5 <<<"$line")")
fi

# the session the log belongs to: every conversation of its directory that was
# still being answered in once the session had started
if [[ -z ${convs[0]-} && -n $dir && -d $dir/conversations ]]; then
	end=$(last_write "$log" 2>/dev/null || date +%s)
	((end > since)) || end=$(date +%s)
	for at in "$dir"/conversations/*.json; do
		[[ -f $at ]] || continue
		jq -es -e --argjson f $((since * 1000)) --argjson t $((end * 1000)) '
      [.[].conversations[]?.entries[]?.time]
      | (. != []) and (. | max) >= $f and (. | min) <= $t
    ' "$at" >/dev/null 2>&1 && convs+=("$at")
	done
fi
[[ -n ${convs[0]-} || -n $log ]] || die "nothing to count: no conversation and no log"

# the log: the wall time of every answer of the session, and what it ran
answered=0
calls=0
refused=0
if [[ -n $log && -f $log ]]; then
	answered=$(sed -nE 's/^\[Agent\] [^ ]+ answered in ([0-9]+) ms$/\1/p' "$log" |
		awk '{ s += $1 } END { print s + 0 }')
	calls=$(grep -cE '^\[Agent\] [^ ]+ calls ' "$log" || echo 0)
	refused=$(grep -cE '^\[HTTP\] Refused ' "$log" || echo 0)
fi

# the conversation: what it cost and how many it holds. The tokens an answer
# generated are the ones the endpoint counted for it; its context is the prompt
# and those tokens together, so the prompt is what the context has over them.
# An answer spent `system` ms from first byte to last and `generation` of them
# generating, the rest waiting on a tool or on anything else the turn did
tokens=
prompt=
agent=
wall=
turns=
user=
if [[ -n ${convs[0]-} ]]; then
	read -r prompt tokens agent wall turns user <<<"$(jq -rs '
    [.[].conversations[]?.entries[]?] as $e
    | [$e[] | select(.role == "assistant")] as $a
    | [$a[] | select(.stats.context != null)] as $c
    | [ ([$c[].stats.context] | add // 0),
        ([$c[].stats.tokens] | add // 0),
        ([$a[].stats.generation] | add // 0),
        ([$a[].stats.system] | add // 0),
        ($e | length),
        ([$e[] | select(.role == "user")] | length) ] | map(tostring) | join(" ")
  ' "${convs[@]}")"
	((prompt >= tokens)) || prompt=0
	((prompt -= tokens))
fi

# the conversation splits an answer into the time the model spent generating
# and the time the machine spent around it; a log only ever saw the two whole
rest=?
if [[ -n $wall && -n $agent ]] && ((wall >= agent)); then
	rest=$(time_of $((wall - agent)))
elif [[ -n $answered && $answered != 0 ]]; then
	agent=$answered
fi

fields=(
	"$( [[ -n $agent && $agent != 0 ]] && time_of "$agent" || echo ?)"
	"$rest"
	"$( [[ -n $prompt ]] && num_of "$prompt" || echo ?)"
	"$( [[ -n $tokens ]] && num_of "$tokens" || echo ?)"
	"${turns:-?}"
	"${user:-?}"
)

if ((verbose)); then
	say "port   ${port:-none}"
	say "log    ${log:-none}"
	say "held   ${#convs[@]} conversation(s) in ${dir:-unknown}: ${convs[*]-}"
	say "turns  $( [[ -n $wall ]] && time_of "$wall" || echo ?) held, $(time_of "$answered") the whole log saw, $calls calls run, $refused refused"
fi

printf '\xe2\x97\xb7 %s \xc2\xb7 \xe2\x9a\x99 %s \xc2\xb7 \xe2\x86\x91 %s \xc2\xb7 \xe2\x86\x93 %s \xc2\xb7 \xe2\x89\xa1 %s \xc2\xb7 \xe2\x8c\xa8 %s\n' \
	"${fields[@]}"

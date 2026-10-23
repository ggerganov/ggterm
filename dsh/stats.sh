#!/usr/bin/env bash
# Session stats for a dsh session, in the same output shape as pi/stats.sh.
set -eu
usage() {
  printf '%s\n%s\n%s\n%s\n%s\n' \
    "usage: $(basename "$0") [<session-id>]  ->  <agent> <tool> <in> <out> <msgs> <user>" \
    "agent: HH.Hh | MM.Mm | SS.Ss, model time: sum of the gap from the preceding record to every" \
    "assistant/message (dsh records carry no durationMs, so that gap is the model's turn share)" \
    "tool:  same units, tool time: per turn, last tool/result - the turn's last assistant/message" \
    "in/out: sum of usage.inputTokens / outputTokens, k = 1e3, m = 1e6 (floored); cache reads are" \
    "not counted as input.  msgs/user: all messages (assistant, user, tool result, system) / user"
  exit 1
}
case ${1-} in -h|--help) usage ;; esac

sid=${1-${DSH_SESSION_ID:-}}
[ -n "$sid" ] || usage

home=${DSH_HOME:-"$HOME/.dsh"}
f=$(find "$home/sessions" -type f -name '*.jsonl.zstd' -path "*session-$sid*" -print -quit 2>/dev/null || true)
[ -n "$f" ] || { printf 'no session record for %s under %s\n' "$sid" "$home/sessions" >&2; exit 1; }

zstd -dc "$f" 2>/dev/null | jq -rs '
def num: if . >= 1000000 then (. / 1000000 | floor | tostring) + "m"
         elif . >= 1000 then (. / 1000 | floor | tostring) + "k"
         else (. | floor | tostring) end;
def time: if . >= 3600 then ((. * 10 / 3600 | round) / 10 | tostring | if test("[.]") then . else . + ".0" end) + "h"
          elif . >= 60 then ((. * 10 / 60 | round) / 10 | tostring | if test("[.]") then . else . + ".0" end) + "m"
          else ((. * 10 | round) / 10 | tostring | if test("[.]") then . else . + ".0" end) + "s" end;
def pos: if . < 0 then 0 else . end;
def usage_of($t; $f): [ .[] | select(.type == $t) | (((.data.usage // {})[$f]) // 0) ] | add // 0;
[ .[] | select((.time | type) == "number") | . + {t: .time} ] | sort_by(.t) as $e
| ([ $e | to_entries[] | select(.value.type == "assistant/message")
     | (.value.t - (if .key == 0 then .value.t else $e[.key - 1].t end)) | pos ] | add // 0) as $agent
| ([ $e | group_by([.data.turn, .data.step])[]
     | ([ .[] | select(.type == "assistant/message") | .t ] | max) as $reply
     | ([ .[] | select(.type == "tool/result") | .t ] | max) as $end
     | (if $reply == null or $end == null then 0 else ($end - $reply) end) | pos ] | add // 0) as $tool
| ($e | usage_of("assistant/message"; "inputTokens")) as $in
| ($e | usage_of("assistant/message"; "outputTokens")) as $out
| ([ $e[] | select(.type == "assistant/message" or .type == "user/message" or .type == "tool/result" or .type == "system/message") ] | length) as $msgs
| ([ $e[] | select(.type == "user/message") ] | length) as $user
| [ ($agent / 1000 | time), ($tool / 1000 | time), ($in | num), ($out | num), ($msgs | tostring), ($user | tostring) ] | join(" ")
'

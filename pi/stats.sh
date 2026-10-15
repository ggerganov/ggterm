#!/usr/bin/env bash
set -eu
usage() {
  printf '%s
  %s
  %s
  %s
' \
    "usage: $(basename "$0") <session.jsonl>  ->  <time> <in> <out> <msgs> <user>" \
    "time: HH.Hh | MM.Mm | SS.Ss, sum of every user message -> last message before the next one" \
    "in/out: total input / output tokens, k = 1e3, m = 1e6 (floored)" \
    "msgs/user: number of all messages (user, assistant, toolResult, system) / user messages only"
  exit 1
}
case ${1-} in ''|-h|--help) usage ;; esac
f=$1
jq -rs '
def dot: ".";
def frac: (. / 10 | floor | tostring) + dot + (. % 10 | tostring);
def time: if . >= 3600 then (. * 10 / 3600 | round | frac) + "h"
          elif . >= 60 then (. * 10 / 60 | round | frac) + "m"
          else (. * 10 | round | frac) + "s" end;
def num: if . >= 1000000 then (. / 1000000 | floor | tostring) + "m"
         elif . >= 1000 then (. / 1000 | floor | tostring) + "k"
         else tostring end;
[.[] | select(.type == "message")] as $m
| ($m | length) as $n
| ([$m[] | select(.message.role == "user")] | length) as $u
| ([$m[] | .message.usage.input // 0] | add // 0) as $i
| ([$m[] | .message.usage.output // 0] | add // 0) as $o
| ([$m | to_entries[] | select(.value.message.role == "user") | .key]) as $ui
| ([$ui[] as $k
   | ((([$ui[] | select(. > $k)] | min) // $n) - 1) as $e
   | $m[$e].message.timestamp - $m[$k].message.timestamp
   ] | add // 0) as $d
| ($d / 1000 | time) + " " + ($i | num) + " " + ($o | num) + " " + ($n | tostring) + " " + ($u | tostring)
' "$f"

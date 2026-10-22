#!/usr/bin/env bash
set -eu
usage() {
  printf '%s
  %s
  %s
  %s
  %s
  %s
  %s
' \
    "usage: $(basename "$0") <session.jsonl>  ->  <agent> <tool> <in> <out> <msgs> <user>" \
    "agent: HH.Hh | MM.Mm | SS.Ss, model time: sum of the durationMs of every assistant message" \
    "tool:  same units, tool time: per turn, last tool result timestamp - end of the reply calling it" \
    "in/out: total input / output tokens, k = 1e3, m = 1e6 (floored)" \
    "msgs/user: number of all messages (user, assistant, toolResult, system) / user messages only" \
    "a message timestamp is the start of a reply, the end of a tool result; sessions without" \
    "durationMs have no split: their whole turn gap is reported as agent time"
  exit 1
}
case ${1-} in ''|-h|--help) usage ;; esac
f=$1
jq -rs '
def dot: ".";
def pos: if . < 0 then 0 else . end;
def frac: (. / 10 | floor | tostring) + dot + (. % 10 | tostring);
def time: if . >= 3600 then (. * 10 / 3600 | round | frac) + "h"
          elif . >= 60 then (. * 10 / 60 | round | frac) + "m"
          else (. * 10 | round | frac) + "s" end;
def num: if . >= 1000000 then (. / 1000000 | floor | tostring) + "m"
         elif . >= 1000 then (. / 1000 | floor | tostring) + "k"
         else tostring end;
# note: jq 1.7 needs the reduce wrapped in parens to bind its result with `as`
def batch_end($m; $i): (reduce range($i; $m | length) as $j (null;
  if . == null and $m[$j].message.role != "toolResult" then $j else . end)) as $b
  | ($b // ($m | length)) as $e
  | if $e > $i then ([$m[$i:$e][].message.timestamp] | max) else null end;
[.[] | select(.type == "message")] as $m
| ($m | length) as $n
| ([$m[] | select(.message.role == "user")] | length) as $u
| ([$m[] | .message.usage.input // 0] | add // 0) as $i
| ([$m[] | .message.usage.output // 0] | add // 0) as $o
| ([$m | to_entries[]
   | select(.value.message.role == "assistant")
   | .key as $k
   | .value.message.durationMs
     // (($m[$k + 1].message.timestamp // .value.message.timestamp) - .value.message.timestamp | pos)
  ] | add // 0) as $agent
| ([$m | to_entries[]
   | select(.value.message.role == "assistant" and .value.message.durationMs != null)
   | .key as $k
   | batch_end($m; $k + 1) as $end
   | select($end != null)
   | ($end - .value.message.timestamp - .value.message.durationMs | pos)
  ] | add // 0) as $tool
| (($agent / 1000 | time) + " " + ($tool / 1000 | time) + " "
   + ($i | num) + " " + ($o | num) + " " + ($n | tostring) + " " + ($u | tostring))
' "$f"

#!/bin/bash
# mcp-call.sh: run one command on a fleet machine through its ggmcp MCP server.
#
# The harness caches an MCP session per server. When a machine restarts its ggmcp
# (every ./start-<machine>.sh does), that session is gone and the harness tools
# answer session_not_found until it reconnects. This opens a session of its own.
#
#   skill/llama-fleet-update/mcp-call.sh <ip> <alias> '<remote command>'
#   skill/llama-fleet-update/mcp-call.sh 100.109.1.92 m5-0 'uptime; pgrep -fl llama-server'
#
# The remote ggmcp applies its own timeout (60 s by default), so keep the command
# short and detach anything long-running on the machine itself.

set -u

if [ $# -lt 3 ] ; then
    echo "usage: $(basename "$0") <ip> <alias> '<remote command>'" >&2
    exit 1
fi

host=$1
alias_=$2
shift 2
command_to_run=$*
port=${GGMCP_PORT:-9933}
timeout=${MCP_CALL_TIMEOUT:-120}

headers=$(mktemp) || exit 1
trap 'rm -f "$headers"' EXIT

session=$(curl -sS -m 15 -D "$headers" -o /dev/null -X POST "http://$host:$port/mcp" \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json, text/event-stream' \
    -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"ggterm-fleet-update","version":"0"}}}' \
    < /dev/null | tr -d '\r' ; grep -i '^mcp-session-id:' "$headers" | tr -d '\r' | awk '{print $2}')

if [ -z "$session" ] ; then
    echo "[!] $host:$port gave no Mcp-Session-Id (is ggmcp up?)" >&2
    exit 1
fi

curl -sS -m 15 -o /dev/null -X POST "http://$host:$port/mcp" -H "Mcp-Session-Id: $session" \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json, text/event-stream' \
    -d '{"jsonrpc":"2.0","method":"notifications/initialized"}' < /dev/null

request=$(python3 -c 'import json,sys; print(json.dumps({"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":sys.argv[1],"arguments":{"command":sys.argv[2]}}}))' \
    "$alias_-bash" "$command_to_run") || exit 1

curl -sS -m "$timeout" -X POST "http://$host:$port/mcp" -H "Mcp-Session-Id: $session" \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json, text/event-stream' \
    -d "$request" < /dev/null \
| sed 's/^data: //' \
| python3 -c '
import json,sys

for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    reply = json.loads(line)
    if "error" in reply:
        print("ERROR", json.dumps(reply["error"]), file=sys.stderr)
        sys.exit(1)
    for part in reply.get("result", {}).get("content", []):
        text = part.get("text", "")
        try:
            out = json.loads(text)
        except ValueError:
            sys.stdout.write(text + "\n")
            continue
        sys.stdout.write(str(out.get("stdout", "")) + str(out.get("stderr", "")))
        sys.exit(int(out.get("exitCode") or 0))
'

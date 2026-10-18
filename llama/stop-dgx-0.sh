#!/bin/bash

set -e

BASE_DIR=${BASE_DIR:-$(cd "$(dirname "$0")" && pwd)}
cd "$BASE_DIR"

LLAMA_SERVER=$BASE_DIR/llama.cpp/build/bin/llama-server
GGMCP=$BASE_DIR/ggmcp/build/ggmcp
RPC_SERVER=$BASE_DIR/llama.cpp/build/bin/ggml-rpc-server

LOG_LLAMA=$BASE_DIR/log-llama.txt
LOG_GGMCP=$BASE_DIR/log-ggmcp.txt
LOG_RPC=$BASE_DIR/log-rpc.txt

mkdir -p "$BASE_DIR/logs"

stop_proc() {
    local name=$1
    local pattern=$2
    local pidfile=$BASE_DIR/$name.pid
    local pids="$(pgrep -f "$pattern" | tr '\n' ' ')"

    if [ -f "$pidfile" ] ; then
        pids="$pids $(cat "$pidfile")"
        rm -f "$pidfile"
    fi

    pids=$(echo $pids | tr ' ' '\n' | sort -un | tr '\n' ' ')
    pids=$(echo $pids)

    if [ -z "$pids" ] ; then
        echo "[+] No running $name found"
        return
    fi

    echo "[+] Stopping old $name: $pids"
    local pid left
    for pid in $pids ; do
        echo "    - $pid: $(ps -p $pid -o args= 2>/dev/null)"
        kill "$pid" 2>/dev/null || true
    done

    for _ in $(seq 1 20) ; do
        left=""
        for pid in $pids ; do
            if kill -0 "$pid" 2>/dev/null ; then
                left="$left $pid"
            fi
        done
        if [ -z "$(echo $left)" ] ; then
            break
        fi
        sleep 0.5
    done

    if [ -n "$(echo $left)" ] ; then
        echo "[+] Force killing $name: $(echo $left)"
        kill -9 $(echo $left) 2>/dev/null || true
    else
        echo "[+] Stopped $name"
    fi
}

stop_proc llama-server "$LLAMA_SERVER"
stop_proc ggmcp "$GGMCP"
stop_proc rpc-server "$RPC_SERVER"

echo "[+] Done"

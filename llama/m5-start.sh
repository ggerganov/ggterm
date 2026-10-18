#!/bin/bash

set -e

BASE_DIR=${BASE_DIR:-$(cd "$(dirname "$0")" && pwd)}
cd "$BASE_DIR"

LLAMA_SERVER=$BASE_DIR/llama.cpp/build/bin/llama-server
GGMCP=$BASE_DIR/ggmcp/build/ggmcp

LOG_LLAMA=$BASE_DIR/log-llama.txt
LOG_GGMCP=$BASE_DIR/log-ggmcp.txt

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

start_proc() {
    local name=$1
    local log=$2
    local bin=$3
    shift 3

    if [ ! -x "$bin" ] ; then
        echo "[!] $bin not found. Run ./m5-setup.sh first"
        exit 1
    fi

    echo "[+] Starting $name -> $log"
    if command -v setsid &> /dev/null ; then
        nohup setsid "$bin" "$@" > "$log" 2>&1 &
    else
        nohup "$bin" "$@" > "$log" 2>&1 &
    fi
    echo $! > "$BASE_DIR/$name.pid"
}

stop_proc llama-server "$LLAMA_SERVER"
stop_proc ggmcp "$GGMCP"
sleep 1

start_proc llama-server "$LOG_LLAMA" "$LLAMA_SERVER" \
    --models-preset preset-m5-128gb/preset.ini \
    --log-prompts-dir ./logs \
    --fit off \
    --host 0.0.0.0 \
    --port 9931 \
    -lv 4 \
    --models-max 1 \
    --cors-origins '*' \
    --agent

start_proc ggmcp "$LOG_GGMCP" "$GGMCP" \
    --host 0.0.0.0 \
    --port 9932 \
    --alias m5 \
    --instructions "Tools for the MacBook M5 Max (m5)"

echo "[+] Done"

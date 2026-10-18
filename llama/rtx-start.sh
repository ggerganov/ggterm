#!/bin/bash

set -e

BASE_DIR=${BASE_DIR:-$(pwd)}
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

    if [ -f "$pidfile" ] ; then
        local pid=$(cat "$pidfile")
        if kill -0 "$pid" 2>/dev/null ; then
            echo "[+] Stopping $name (pid $pid)"
            kill "$pid"
        fi
        rm -f "$pidfile"
    fi

    pkill -f "$pattern" 2>/dev/null || true
}

start_proc() {
    local name=$1
    local log=$2
    local bin=$3
    shift 3

    if [ ! -x "$bin" ] ; then
        echo "[!] $bin not found. Run ./rtx-setup.sh first"
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
sleep 2

export CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES:-0}

start_proc llama-server "$LOG_LLAMA" "$LLAMA_SERVER" \
    --models-preset preset-cuda-32gb/preset.ini \
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
    --alias rtx \
    --instructions "Tools for the RTX 5090 machine (rtx)"

echo "[+] Done"

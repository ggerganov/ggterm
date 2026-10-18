#!/bin/bash

set -e

BASE_DIR=${BASE_DIR:-$(pwd)}
cd "$BASE_DIR"

LLAMA_SERVER=$BASE_DIR/llama.cpp/build/bin/llama-server
GGMCP=$BASE_DIR/ggmcp/build/ggmcp

LOG_DIR=$BASE_DIR/logs
mkdir -p "$LOG_DIR"

stop_proc() {
    local name=$1
    local pattern=$2
    local pidfile=$LOG_DIR/$name.pid

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
    local bin=$2
    shift 2

    if [ ! -x "$bin" ] ; then
        echo "[!] $bin not found. Run ./rtx-setup.sh first"
        exit 1
    fi

    echo "[+] Starting $name -> $LOG_DIR/$name.log"
    if command -v setsid &> /dev/null ; then
        nohup setsid "$bin" "$@" > "$LOG_DIR/$name.log" 2>&1 &
    else
        nohup "$bin" "$@" > "$LOG_DIR/$name.log" 2>&1 &
    fi
    echo $! > "$LOG_DIR/$name.pid"
}

stop_proc llama-server "$LLAMA_SERVER"
stop_proc ggmcp "$GGMCP"
sleep 2

export CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES:-0}

start_proc llama-server "$LLAMA_SERVER" \
    --models-preset preset-cuda-32gb/preset.ini \
    --log-prompts-dir ./logs \
    --fit off \
    --host 0.0.0.0 \
    --port 9931 \
    -lv 4 \
    --models-max 1 \
    --cors-origins '*' \
    --agent

start_proc ggmcp "$GGMCP" \
    --host 0.0.0.0 \
    --port 9932 \
    --alias rtx \
    --instructions "Tools for the RTX 5090 machine (rtx)"

echo "[+] Done"

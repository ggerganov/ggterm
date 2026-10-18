#!/bin/bash

set -e

BASE_DIR=${BASE_DIR:-$(cd "$(dirname "$0")" && pwd)}
export BASE_DIR
cd "$BASE_DIR"

LLAMA_SERVER=$BASE_DIR/llama.cpp/build/bin/llama-server
GGMCP=$BASE_DIR/ggmcp/build/ggmcp

LOG_LLAMA=$BASE_DIR/log-llama.txt
LOG_GGMCP=$BASE_DIR/log-ggmcp.txt

mkdir -p "$BASE_DIR/logs"

start_proc() {
    local name=$1
    local log=$2
    local bin=$3
    shift 3

    if [ ! -x "$bin" ] ; then
        echo "[!] $bin not found. Run ./setup-m5.sh first"
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

bash "$BASE_DIR/stop-m5.sh"
sleep 1

start_proc llama-server "$LOG_LLAMA" "$LLAMA_SERVER" \
    --models-preset preset-m5-128gb/preset.ini \
    --log-prompts-dir ./logs \
    --fit off \
    --host 0.0.0.0 \
    --port 9932 \
    -lv 4 \
    --models-max 1 \
    --cors-origins '*' \
    --agent

start_proc ggmcp "$LOG_GGMCP" "$GGMCP" \
    --host 0.0.0.0 \
    --port 9933 \
    --alias m5 \
    --instructions "Tools for the MacBook M5 Max (m5)"

echo "[+] Done"

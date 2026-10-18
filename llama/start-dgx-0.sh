#!/bin/bash

set -e

BASE_DIR=${BASE_DIR:-$(cd "$(dirname "$0")" && pwd)}
export BASE_DIR
cd "$BASE_DIR"

LLAMA_SERVER=$BASE_DIR/llama.cpp/build/bin/llama-server
GGMCP=$BASE_DIR/ggmcp/build/ggmcp
RPC_SERVER=$BASE_DIR/llama.cpp/build/bin/ggml-rpc-server

LOG_LLAMA=$BASE_DIR/log-llama.txt
LOG_GGMCP=$BASE_DIR/log-ggmcp.txt
LOG_RPC=$BASE_DIR/log-rpc.txt

mkdir -p "$BASE_DIR/logs"

start_proc() {
    local name=$1
    local log=$2
    local bin=$3
    shift 3

    if [ ! -x "$bin" ] ; then
        echo "[!] $bin not found. Run ./setup-dgx-0.sh first"
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

bash "$BASE_DIR/stop-dgx-0.sh"
sleep 1

export CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES:-0}

start_proc rpc-server "$LOG_RPC" "$RPC_SERVER" \
    --host 0.0.0.0 \
    --port 50052 \
    -d CUDA0 \
    -c

start_proc llama-server "$LOG_LLAMA" "$LLAMA_SERVER" \
    --models-preset preset-dgx-128gb/preset.ini \
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
    --alias spark-0 \
    --instructions "Tools running on spark-0"

echo "[+] Done"

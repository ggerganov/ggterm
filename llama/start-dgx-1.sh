#!/bin/bash

set -e

BASE_DIR=${BASE_DIR:-$(cd "$(dirname "$0")" && pwd)}
export BASE_DIR
cd "$BASE_DIR"

RPC_SERVER=$BASE_DIR/llama.cpp/build/bin/ggml-rpc-server
GGMCP=$BASE_DIR/ggmcp/build/ggmcp

LOG_RPC=$BASE_DIR/log-rpc.txt
LOG_GGMCP=$BASE_DIR/log-ggmcp.txt

start_proc() {
    local name=$1
    local log=$2
    local bin=$3
    shift 3

    if [ ! -x "$bin" ] ; then
        echo "[!] $bin not found. Run ./setup-dgx-1.sh first"
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

bash "$BASE_DIR/stop-dgx-1.sh"
sleep 1

start_proc rpc-server "$LOG_RPC" "$RPC_SERVER" \
    --host 0.0.0.0 \
    --port 50052 \
    -d CUDA0 \
    -c

start_proc ggmcp "$LOG_GGMCP" "$GGMCP" \
    --host 0.0.0.0 \
    --port 9933 \
    --alias spark-1 \
    --instructions "Tools running on spark-1"

echo "[+] Done"

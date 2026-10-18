#!/bin/bash

set -e

BASE_DIR=${BASE_DIR:-$(cd "$(dirname "$0")" && pwd)}
MACHINE='dgx-0'
source "$BASE_DIR/common.sh"

export CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES:-0}

bash "$BASE_DIR/stop-dgx-0.sh"
sleep 1

start_rpc_server
start_llama_server preset-dgx-128gb
start_ggmcp spark-0 'Tools running on DGX Spark (spark-0). See README-MCP.md for more info.'

echo "[+] Done"

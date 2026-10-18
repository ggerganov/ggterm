#!/bin/bash

set -e

BASE_DIR=${BASE_DIR:-$(cd "$(dirname "$0")" && pwd)}
MACHINE='dgx-1'
source "$BASE_DIR/common.sh"

export CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES:-0}

bash "$BASE_DIR/stop-dgx-1.sh"
sleep 1

start_rpc_server
start_ggmcp spark-1 "Tools running on spark-1"

echo "[+] Done"

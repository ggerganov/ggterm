#!/bin/bash

set -e

BASE_DIR=${BASE_DIR:-$(cd "$(dirname "$0")" && pwd)}
MACHINE='rtx'
source "$BASE_DIR/common.sh"

export CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES:-0}

bash "$BASE_DIR/stop-rtx.sh"
sleep 1

start_llama_server preset-rtx-32gb
start_ggmcp rtx "Tools for the RTX 5090 machine (rtx)"

echo "[+] Done"

#!/bin/bash

set -e

BASE_DIR=${BASE_DIR:-$(cd "$(dirname "$0")" && pwd)}
MACHINE='strix-1'
source "$BASE_DIR/common.sh"

setup_repo https://github.com/ggml-org/llama.cpp master 1 -DGGML_VULKAN=ON -DGGML_RPC=ON
setup_repo https://github.com/ggerganov/ggmcp gg/qwen4-2 1

echo "[+] Done"

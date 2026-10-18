#!/bin/bash

set -e

BASE_DIR=${BASE_DIR:-$(cd "$(dirname "$0")" && pwd)}
MACHINE='dgx-0'
source "$BASE_DIR/common.sh"

setup_repo https://github.com/ggml-org/llama.cpp gg/glm5 1 -DGGML_CUDA=ON -DGGML_RPC=ON
setup_repo https://github.com/ggerganov/ggmcp gg/qwen4-2 1

echo "[+] Done"

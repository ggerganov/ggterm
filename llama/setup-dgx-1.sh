#!/bin/bash

set -e

BASE_DIR=${BASE_DIR:-$(cd "$(dirname "$0")" && pwd)}
MACHINE='dgx-1'
LLAMA_REF=gg/glm5
GGMCP_REF=gg/qwen4-2
KISS_REF=master
source "$BASE_DIR/common.sh"
parse_args "$@"

setup_repo https://github.com/ggml-org/llama.cpp "$LLAMA_REF" 1 -DGGML_CUDA=ON -DGGML_RPC=ON
setup_repo https://github.com/ggerganov/ggmcp "$GGMCP_REF" 1

setup_repo https://github.com/ggerganov/kiss-manager "$KISS_REF" 0
setup_submodules "$KISS_MANAGER_DIR"
setup_build kiss-manager "$KISS_MANAGER_DIR"

echo "[+] Done"

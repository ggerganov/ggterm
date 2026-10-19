#!/bin/bash

set -e

BASE_DIR=${BASE_DIR:-$(cd "$(dirname "$0")" && pwd)}
MACHINE='m2'
LLAMA_REF=master
GGMCP_REF=gg/qwen4-2
source "$BASE_DIR/common.sh"
parse_args "$@"

setup_repo https://github.com/ggml-org/llama.cpp "$LLAMA_REF" 1
setup_repo https://github.com/ggerganov/ggmcp "$GGMCP_REF" 1

echo "[+] Done"

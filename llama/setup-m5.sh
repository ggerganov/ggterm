#!/bin/bash

set -e

BASE_DIR=${BASE_DIR:-$(cd "$(dirname "$0")" && pwd)}
MACHINE='m5'
source "$BASE_DIR/common.sh"

setup_repo https://github.com/ggml-org/llama.cpp master 1
setup_repo https://github.com/ggerganov/ggmcp gg/qwen4-2 1

echo "[+] Done"

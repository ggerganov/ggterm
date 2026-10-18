#!/bin/bash

set -e

BASE_DIR=${BASE_DIR:-$(cd "$(dirname "$0")" && pwd)}
MACHINE='m5'
source "$BASE_DIR/common.sh"

bash "$BASE_DIR/stop-m5.sh"
sleep 1

start_llama_server preset-m5-128gb
start_ggmcp m5 "Tools for the MacBook M5 Max (m5)"

echo "[+] Done"

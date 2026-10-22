#!/bin/bash

set -e

BASE_DIR=${BASE_DIR:-$(cd "$(dirname "$0")" && pwd)}
MACHINE='m5-0'
source "$BASE_DIR/common.sh"

bash "$BASE_DIR/stop-m5-0.sh"
sleep 1

start_llama_server preset-m5-0-48gb
start_ggmcp m5-0 'Tools for the MacBook M5 (m5-0). See README-MCP.md for more info.'

start_kiss_manager

echo "[+] Done"

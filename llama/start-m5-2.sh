#!/bin/bash

set -e

BASE_DIR=${BASE_DIR:-$(cd "$(dirname "$0")" && pwd)}
MACHINE='m5-2'
source "$BASE_DIR/common.sh"

bash "$BASE_DIR/stop-m5-2.sh"
sleep 1

start_llama_server preset-m5-2-256gb
start_ggmcp m5-2 'Tools for the Mac Studio M5 Ultra (m5-2). See README-MCP.md for more info.'

start_kiss_manager

echo "[+] Done"

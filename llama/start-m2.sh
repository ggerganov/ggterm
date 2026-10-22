#!/bin/bash

set -e

BASE_DIR=${BASE_DIR:-$(cd "$(dirname "$0")" && pwd)}
MACHINE='m2'
source "$BASE_DIR/common.sh"

bash "$BASE_DIR/stop-m2.sh"
sleep 1

start_llama_server preset-m2-192gb
start_ggmcp m2 'Tools for the Mac Studio M2 Ultra (m2). See README-MCP.md for more info.'

start_kiss_manager

echo "[+] Done"

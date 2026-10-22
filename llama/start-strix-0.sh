#!/bin/bash

set -e

BASE_DIR=${BASE_DIR:-$(cd "$(dirname "$0")" && pwd)}
MACHINE='strix-0'
source "$BASE_DIR/common.sh"

bash "$BASE_DIR/stop-strix-0.sh"
sleep 1

start_rpc_server Vulkan0
start_llama_server preset-strix-128gb
start_ggmcp strix-0 'Tools running on Strix Halo (strix-0). See README-MCP.md for more info.'

start_kiss_manager

echo "[+] Done"

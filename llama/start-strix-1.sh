#!/bin/bash

set -e

BASE_DIR=${BASE_DIR:-$(cd "$(dirname "$0")" && pwd)}
MACHINE='strix-1'
source "$BASE_DIR/common.sh"

bash "$BASE_DIR/stop-strix-1.sh"
sleep 1

start_rpc_server Vulkan0
start_ggmcp strix-1 'Tools running on Strix Halo (strix-1). See README-MCP.md for more info.'

start_kiss_manager

echo "[+] Done"

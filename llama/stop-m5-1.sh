#!/bin/bash

set -e

BASE_DIR=${BASE_DIR:-$(cd "$(dirname "$0")" && pwd)}
MACHINE='m5-1'
source "$BASE_DIR/common.sh"

stop_machine

echo "[+] Done"

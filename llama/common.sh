#!/bin/bash
# shared helpers for the per-machine llama.cpp scripts
# machine scripts must set BASE_DIR and MACHINE before sourcing

LLAMA_DIR=${LLAMA_DIR:-$BASE_DIR/llama.cpp}
GGMCP_DIR=${GGMCP_DIR:-$BASE_DIR/ggmcp}
LLAMA_SERVER=$LLAMA_DIR/build/bin/llama-server
GGMCP=$GGMCP_DIR/build/ggmcp
RPC_SERVER=$LLAMA_DIR/build/bin/ggml-rpc-server

LOG_LLAMA=$BASE_DIR/log-llama.txt
LOG_GGMCP=$BASE_DIR/log-ggmcp.txt
LOG_RPC=$BASE_DIR/log-rpc.txt
SCRATCH_DIR=${SCRATCH_DIR:-$HOME/scratch}

LLAMA_PORT=${LLAMA_PORT:-9932}
GGMCP_PORT=${GGMCP_PORT:-9933}
RPC_PORT=${RPC_PORT:-50052}

setup_repo() {
    local repo=$1
    local branch=$2
    local build=$3
    shift 3

    local name=$(basename "$repo")
    local dir=$BASE_DIR/$name

    if [ -d "$dir/.git" ] ; then
        echo "[+] Updating $dir ($branch)"
        git -C "$dir" fetch origin "$branch"
        git -C "$dir" checkout "$branch"
        git -C "$dir" reset --hard "origin/$branch"
    else
        echo "[+] Cloning $repo ($branch) into $dir"
        git clone --branch "$branch" "$repo" "$dir"
    fi

    if command -v git-lfs &> /dev/null ; then
        git -C "$dir" lfs pull
    fi

    if [ "$build" = "1" ] ; then
        echo "[+] Building $name"
        cmake -S "$dir" -B "$dir/build" "$@"
        cmake --build "$dir/build" -j
    fi
}

stop_proc() {
    local name=$1
    local pattern=$2
    local pidfile=$BASE_DIR/$name.pid
    local pids="$(pgrep -f "$pattern" | tr '\n' ' ')"

    if [ -f "$pidfile" ] ; then
        pids="$pids $(cat "$pidfile")"
        rm -f "$pidfile"
    fi

    pids=$(echo $pids | tr ' ' '\n' | sort -un | tr '\n' ' ')
    pids=$(echo $pids)

    if [ -z "$pids" ] ; then
        echo "[+] No running $name found"
        return
    fi

    echo "[+] Stopping old $name: $pids"
    local pid left
    for pid in $pids ; do
        echo "    - $pid: $(ps -p $pid -o args= 2>/dev/null)"
        kill "$pid" 2>/dev/null || true
    done

    for _ in $(seq 1 20) ; do
        left=""
        for pid in $pids ; do
            if kill -0 "$pid" 2>/dev/null ; then
                left="$left $pid"
            fi
        done
        if [ -z "$(echo $left)" ] ; then
            break
        fi
        sleep 0.5
    done

    if [ -n "$(echo $left)" ] ; then
        echo "[+] Force killing $name: $(echo $left)"
        kill -9 $(echo $left) 2>/dev/null || true
    else
        echo "[+] Stopped $name"
    fi
}

start_proc() {
    local name=$1
    local log=$2
    local bin=$3
    shift 3

    if [ ! -x "$bin" ] ; then
        echo "[!] $bin not found. Run ./setup-$MACHINE.sh first"
        exit 1
    fi

    mkdir -p "$(dirname "$log")"
    local pidfile=$BASE_DIR/$name.pid
    local cwd=${CWD_OVERRIDE:-$BASE_DIR}

    echo "[+] Starting $name -> $log"

    local oldpwd=$(pwd)
    cd "$cwd"
    if command -v setsid &> /dev/null ; then
        nohup setsid "$bin" "$@" > "$log" 2>&1 &
    else
        nohup "$bin" "$@" > "$log" 2>&1 &
    fi
    echo $! > "$pidfile"
    cd "$oldpwd"
}

start_ggmcp() {
    local alias=$1
    local instructions=$2

    mkdir -p "$SCRATCH_DIR"
    if [ ! -f "$SCRATCH_DIR/README-MCP.md" ] ; then
        echo "[+] Creating $SCRATCH_DIR/README-MCP.md"
        cat > "$SCRATCH_DIR/README-MCP.md" <<'EOF'
# MCP scratch

This directory is the working directory of the ggmcp server.

Use it to clone repositories, build, run, test and do any other temporary or
fleeting work an MCP session needs.
EOF
    fi

    CWD_OVERRIDE=$SCRATCH_DIR start_proc ggmcp "$LOG_GGMCP" "$GGMCP" \
        --host 0.0.0.0 \
        --port "$GGMCP_PORT" \
        --alias "$alias" \
        --instructions "$instructions"
}

start_llama_server() {
    local preset=$1

    mkdir -p "$BASE_DIR/logs"
    start_proc llama-server "$LOG_LLAMA" "$LLAMA_SERVER" \
        --models-preset "$preset/preset.ini" \
        --log-prompts-dir ./logs \
        --fit off \
        --host 0.0.0.0 \
        --port "$LLAMA_PORT" \
        -lv 4 \
        --models-max 1 \
        --cors-origins '*' \
        --agent
}

start_rpc_server() {
    start_proc rpc-server "$LOG_RPC" "$RPC_SERVER" \
        --host 0.0.0.0 \
        --port "$RPC_PORT" \
        -d CUDA0 \
        -c
}

stop_machine() {
    stop_proc llama-server "$LLAMA_SERVER"
    stop_proc ggmcp "$GGMCP"
    stop_proc rpc-server "$RPC_SERVER"
}

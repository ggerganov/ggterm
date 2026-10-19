#!/bin/bash
# shared helpers for the per-machine llama.cpp scripts
# machine scripts must set BASE_DIR and MACHINE before sourcing

# the setup scripts take the git ref of each repo as an argument: a branch, a
# tag or a commit hash. A hash is any 7-40 char hex string and is pinned in
# detached HEAD:
#   ./setup-rtx.sh                                   # machine defaults
#   ./setup-rtx.sh --llama gg/glm5                   # branch or tag
#   ./setup-rtx.sh --llama master --ggmcp gg/qwen4-2 # both repos
#   ./setup-rtx.sh --llama 098ce526b546b5a190327c1da82929cee051b9ac  # commit

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

setup_usage() {
    echo "usage: $(basename "$0") [--llama <ref>] [--ggmcp <ref>]"
    echo "       <ref> is a branch, a tag or a commit hash"
    echo "       default: --llama $LLAMA_REF --ggmcp $GGMCP_REF"
}

# parse the setup scripts' arguments, the machine script sets the default refs
parse_args() {
    local flag

    while [ $# -gt 0 ] ; do
        case $1 in
            --llama|--ggmcp)
                flag=$1
                shift

                if [ -z "${1:-}" ] || [ "${1#-}" != "$1" ] ; then
                    echo "[!] $flag requires a ref"
                    setup_usage
                    exit 1
                fi

                if [ "$flag" = "--llama" ] ; then
                    LLAMA_REF=$1
                else
                    GGMCP_REF=$1
                fi
                shift
                ;;
            -h|--help)
                setup_usage
                exit 0
                ;;
            *)
                echo "[!] Unknown option: $1"
                setup_usage
                exit 1
                ;;
        esac
    done
}

is_commit() {
    local ref=$1

    case "$ref" in
        '') return 1 ;;
        *[!0-9a-fA-F]*) return 1 ;;
    esac

    [ ${#ref} -ge 7 ] && [ ${#ref} -le 40 ]
}

setup_repo() {
    local repo=$1
    local ref=$2
    local build=$3
    shift 3

    local name=$(basename "$repo")
    local dir=$BASE_DIR/$name
    local commit=0

    if is_commit "$ref" ; then
        commit=1
    fi

    if [ -d "$dir/.git" ] ; then
        echo "[+] Updating $dir ($ref)"

        if [ "$commit" = "1" ] ; then
            # fetch a commit by hash when the server allows it, a full fetch is the fallback
            git -C "$dir" fetch --quiet --tags origin "$ref" 2> /dev/null \
                || git -C "$dir" fetch --quiet --tags --prune origin
        else
            git -C "$dir" fetch --quiet --tags --prune origin
        fi
    else
        echo "[+] Cloning $repo ($ref) into $dir"

        if [ "$commit" = "1" ] ; then
            git clone --quiet "$repo" "$dir"
        else
            git clone --quiet --branch "$ref" "$repo" "$dir"
        fi
    fi

    if [ "$commit" = "1" ] ; then
        if ! git -C "$dir" checkout --quiet --detach "$ref" 2> /dev/null ; then
            echo "[!] $name: commit $ref not found in $dir"
            exit 1
        fi
    elif ! git -C "$dir" checkout --quiet "$ref" 2> /dev/null ; then
        echo "[!] $name: ref $ref not found in $dir"
        exit 1
    fi

    # a branch is kept on top of its remote tip, a tag stays where it is
    if git -C "$dir" rev-parse --quiet --verify "refs/remotes/origin/$ref" > /dev/null ; then
        git -C "$dir" reset --quiet --hard "origin/$ref"
    fi

    echo "    - HEAD: $(git -C "$dir" rev-parse --short HEAD) $(git -C "$dir" log -1 --format=%s)"

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
    local device=${1:-CUDA0}

    start_proc rpc-server "$LOG_RPC" "$RPC_SERVER" \
        --host 0.0.0.0 \
        --port "$RPC_PORT" \
        -d "$device" \
        -c
}

stop_machine() {
    stop_proc llama-server "$LLAMA_SERVER"
    stop_proc ggmcp "$GGMCP"
    stop_proc rpc-server "$RPC_SERVER"
}

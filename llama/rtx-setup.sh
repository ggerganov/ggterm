#!/bin/bash

set -e

BASE_DIR=${BASE_DIR:-$(pwd)}

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

setup_repo https://github.com/ggml-org/llama.cpp master 1 -DGGML_CUDA=ON
setup_repo https://github.com/ggerganov/ggmcp gg/qwen4-2 1
setup_repo https://huggingface.co/ggerganov/preset-cuda-32gb main 0

echo "[+] Done"

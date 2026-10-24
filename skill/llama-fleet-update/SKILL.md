---
name: llama-fleet-update
description: Update and restart one machine of the ggterm llama.cpp fleet (its ggterm clone, llama.cpp, ggmcp and kiss-manager) over that machine's ggmcp MCP server. Use when asked to update, redeploy or restart a fleet machine such as m2, m5-0, m5-1, rtx, dgx-0, dgx-1, strix-0 or strix-1.
---

# Update and restart a fleet machine

Every fleet machine runs the scripts of `llama/` from its own clone of ggterm. One
machine at a time: pull ggterm, `llama/setup-<machine>.sh` rebuilds the three repos,
`llama/start-<machine>.sh` stops the old services and starts the new ones.

Reach the machine through its `ggmcp` MCP server and run everything there. Never
edit a machine by hand, and never touch a machine other than the one asked for.

## The fleet

Read the machine's own scripts before acting — the refs below drift with every
merge, and `setup-<machine>.sh` is the only truth about what gets built.

| Machine | IP | ggmcp alias | llama.cpp | preset | Build flags | Provider id |
| --- | --- | --- | --- | --- | --- | --- |
| `m2` | 100.109.206.95 | `m2` | `master` | `preset-m2-192gb` | — | `llama-mac-m2` |
| `m5-0` | 100.109.1.92 | `m5-0` | `master` | `preset-m5-0-48gb` | — | *(none)* |
| `m5-1` | 100.82.237.74 | `m5-1` | `master` | `preset-m5-1-128gb` | — | `llama-mac-m5-1` |
| `dgx-0` | 100.64.225.101 | `spark-0` | `gg/glm5` | `preset-dgx-128gb` | `-DGGML_CUDA=ON -DGGML_RPC=ON` | `llama-dgx` |
| `dgx-1` | 100.69.125.93 | `spark-1` | `gg/glm5` | *(rpc peer)* | `-DGGML_CUDA=ON -DGGML_RPC=ON` | *(rpc peer)* |
| `rtx` | 100.111.34.101 | `rtx` | `master` | `preset-rtx-32gb` | `-DGGML_CUDA=ON` | `llama-rtx` |
| `strix-0` | 100.112.93.68 | `strix-0` | `master` | `preset-strix-128gb` | `-DGGML_VULKAN=ON -DGGML_RPC=ON` | `llama-strix` |
| `strix-1` | 100.77.67.107 | `strix-1` | `master` | *(rpc peer)* | `-DGGML_VULKAN=ON -DGGML_RPC=ON` | *(rpc peer)* |

Sources of these facts, all under this repo:

- `llama/common.sh` — `MACHINE_HOSTS` (machine id, tailnet IP, MagicDNS name), the
  ports, and every `start_*` / `stop_*` helper.
- `llama/setup-<machine>.sh` — `MACHINE`, `LLAMA_REF`, `GGMCP_REF`, `KISS_REF`, cmake flags.
- `llama/start-<machine>.sh` — the preset it starts and the `ggmcp` alias it registers.
- `llama/kiss.conf` — the fleet's `/v1` endpoints and the `mcp url` of every machine.
- `pi/models.json` — the provider id and models each endpoint answers on.

ggterm lives here on each machine (user, path):

| Machines | User | Clone |
| --- | --- | --- |
| `m2`, `m5-0`, `m5-1` | `ggerganov` | `~/development/github/ggterm` |
| `rtx` | `ggerganov` | `~/ggterm` |
| `dgx-0`, `dgx-1` | `ggml` | `~/development/ggterm` |
| `strix-0`, `strix-1` | `cluster` | `~/development/ggterm` |

Ports a machine serves (`common.sh`): llama-server `9932` (`/v1`), ggmcp `9933`
(`/mcp`), KiSS manager `9934`, KiSS servers from `19000` up, `ggml-rpc-server`
`50052` on the direct peer links of the DGX and Strix pairs.

## Steps

1. **Read the scripts of that machine** — `setup-<machine>.sh`, `start-<machine>.sh`,
   and the helpers of `common.sh`. Take the ref, the preset and the alias from them.
2. **Reach it.** The harness exposes each machine as `mcp__<alias>__<alias>-bash`.
   If a call returns `session_not_found`, that machine's `ggmcp` restarted since the
   harness last bound it: the server is fine, only the cached session is stale. Use
   [mcp-call.sh](mcp-call.sh) to open a session and run a command:

   ```bash
   skill/llama-fleet-update/mcp-call.sh <ip> <alias> '<remote command>'
   ```

3. **Survey before touching anything.** Print the clone's branch and HEAD, its
   `status --porcelain`, the running services and the listening ports. A dirty tree
   is a stop-and-ask, not a `reset --hard`.
4. **Pull ggterm.** `git fetch --prune origin`, `git checkout <branch>`,
   `git pull --ff-only`. A non-fast-forward is a stop-and-ask.
5. **Build.** A llama.cpp build runs for minutes and the MCP call would time out, so
   detach it and poll its log:

   ```bash
   cd <clone>/llama
   nohup ./setup-<machine>.sh > /tmp/setup-<machine>.log 2>&1 </dev/null &
   ```

   Poll `grep -E '^\[\+\]|^    - HEAD|^\[!\]|SETUP_EXIT' /tmp/setup-<machine>.log`
   until `SETUP_EXIT=` shows. The script prints the HEAD it moved each repo to.
6. **Restart.** Detach it the same way, and clear the leaked variable (see below):

   ```bash
   cd <clone>/llama
   env -u CWD_OVERRIDE nohup ./start-<machine>.sh > /tmp/start-<machine>.log 2>&1 </dev/null &
   ```

   The call never returns: `stop_machine` kills the `ggmcp` that is serving it.
7. **Verify over a fresh session** (see the checklist below). Wait ~20 s after the
   start before the first check.
8. **Report** each service with its new pid, port and state, and the old → new commit
   of ggterm, llama.cpp, ggmcp and kiss-manager. Name any machine whose harness MCP
   session now needs a reconnect.
9. **Clean up** the `/tmp` logs and any server you started for testing on its own
   port — the stop scripts will not know about it.

## Verification checklist

```bash
d=<clone>/llama
p=$(cat "$d/llama-server.pid")
echo "llama-server pid=$p alive=$(kill -0 $p 2>/dev/null && echo yes || echo no) cwd=$(lsof -a -p $p -d cwd -Fn | sed -n 's/^n//p')"
grep -E '^\[\+\]' /tmp/start-<machine>.log                  # stopped, then started
grep -iE 'custom model presets|E srv|router mode' "$d/log-llama.txt" | tail -5
curl -sS -m 5 http://<ip>:9932/health                       # {"status":"ok"}
curl -sS -m 10 http://<ip>:9932/v1/models                   # preset aliases and cached models
curl -sS -m 5 -o /dev/null -w '%{http_code}\n' -X POST http://<ip>:9933/mcp \
  -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' -d '{}'
for x in ggmcp kiss rpc; do echo "--- log-$x.txt"; tail -4 "$d/log-$x.txt"; done
pgrep -fl 'build/bin/llama-server|build/ggmcp|build/manager' | cut -c1-90
```

Good is: `llama-server` alive with **cwd = `<clone>/llama`**, `/health` ok, the models
list holding the preset's aliases, `9933` answering `200`, and no `E srv` or `[!]` in
the logs.

## Pitfalls

- **`start-<machine>.sh` kills the `ggmcp` serving your call** (`stop_machine` →
  `stop_proc ggmcp`). A foreground call hangs until it times out and its output is
  lost, and the machine's harness session dies with it. Always detach (step 6) and
  come back on a fresh session.
- **`CWD_OVERRIDE` leaks out of `ggmcp`.** `start_ggmcp` runs
  `CWD_OVERRIDE=$SCRATCH_DIR start_proc ggmcp ...` (`common.sh:301`), and bash puts a
  function-call prefix assignment into that function's children, so the `ggmcp`
  process — and every shell it spawns, including yours — carries
  `CWD_OVERRIDE=<scratch>`. `start_proc` then cds there (`common.sh:269`) and
  llama-server's *relative* `--models-preset preset-.../preset.ini` no longer
  resolves: the log ends with `failed to initialize router models: preset file does
  not exist: preset-<...>/preset.ini` and the server exits, while `ggmcp` and the
  KiSS manager come up fine on their absolute paths. Symptom: only llama-server is
  dead after a restart that reported `[+] Done`. Always `env -u CWD_OVERRIDE`.
- **macOS has no `setsid`**, so `start_proc` falls back to `nohup`; a detached
  `nohup ... &` is enough to survive the death of the calling shell.
- **The MCP bash tool times out at 60 s by default.** Keep remote commands short and
  never run `llama-server` in the foreground inside a check — it loads a model and
  stays up. Test on a scratch port, then kill it.
- **Router mode spawns a child `llama-server` per loaded model** (ports from 19000).
  `stop_proc llama-server` catches them by pattern; a server you started by hand does
  not get caught.
- **The preset is a relative path resolved against the llama dir.** Do not pass an
  absolute path or a different preset to "make it work".
- **`dgx-1` and `strix-1` run only `ggml-rpc-server` and `ggmcp`** — no llama-server,
  no preset, no provider, so `9932` stays closed there and `/v1/models` is not a
  failure.
- **The DGX pair is on `gg/glm5`, not `master`.** Do not "fix" it by pulling master.
- **The KiSS manager does not answer `GET /`** on `9934`; a curl `000` there means
  nothing. Judge it by a listening socket and `Listening on` in `log-kiss.txt`.
- **A machine missing from `MACHINE_HOSTS` starts nothing** unless `BIND_HOST` is
  given. Check the map before blaming the build.
- **Do not pull a dirty clone or kill services you did not start.** Stop and ask.

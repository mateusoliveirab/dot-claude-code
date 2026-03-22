#!/usr/bin/env bash
# serve.sh — Start an opencode headless server for parallel task execution.
#
# Usage:
#   source scripts/serve.sh [port]
#   source scripts/serve.sh 4096
#
# After sourcing, $OC_PORT and $OC_URL are available in the calling shell.
# The server is automatically stopped when the shell exits (via trap).
#
# Example:
#   source scripts/serve.sh
#   opencode run --attach $OC_URL --title "task-1" --model opencode/glm-5-free "..."
#   opencode run --attach $OC_URL --title "task-2" --model opencode/big-pickle "..."

set -euo pipefail

command -v opencode >/dev/null 2>&1 || {
    echo "[opencode] ERROR: 'opencode' not found. Install it first: https://opencode.ai" >&2
    return 1 2>/dev/null || exit 1
}
command -v curl >/dev/null 2>&1 || {
    echo "[opencode] ERROR: 'curl' not found. Required for readiness check." >&2
    return 1 2>/dev/null || exit 1
}

_oc_requested_port="${1:-4096}"
OC_SERVER_PID=""

# Check if requested port is already in use; if so, fall back to a random one
if lsof -ti tcp:"$_oc_requested_port" >/dev/null 2>&1; then
    echo "[opencode] Port $_oc_requested_port is in use, falling back to random port..." >&2
    _oc_requested_port=0
fi

_oc_cleanup() {
    if [[ -n "$OC_SERVER_PID" ]] && kill -0 "$OC_SERVER_PID" 2>/dev/null; then
        echo "[opencode] Stopping server (pid $OC_SERVER_PID)..."
        kill "$OC_SERVER_PID" 2>/dev/null || true
    fi
}
trap _oc_cleanup EXIT

echo "[opencode] Starting server..."
opencode serve --port "$_oc_requested_port" 2>/tmp/oc_serve_stderr &
OC_SERVER_PID=$!

# Detect actual port from stderr output (opencode logs the bound address)
OC_PORT=""
for i in $(seq 1 20); do
    sleep 0.5
    if [[ -f /tmp/oc_serve_stderr ]]; then
        OC_PORT=$(grep -oE 'localhost:[0-9]+|127\.0\.0\.1:[0-9]+|:[0-9]{4,5}' /tmp/oc_serve_stderr 2>/dev/null \
            | grep -oE '[0-9]{4,5}' | head -1 || true)
        [[ -n "$OC_PORT" ]] && break
    fi
    # Also verify process is still alive
    kill -0 "$OC_SERVER_PID" 2>/dev/null || {
        echo "[opencode] ERROR: Server process exited unexpectedly." >&2
        cat /tmp/oc_serve_stderr >&2 || true
        return 1 2>/dev/null || exit 1
    }
done

# Fallback: if we can't parse the port, use the requested one
if [[ -z "$OC_PORT" ]]; then
    OC_PORT="${1:-4096}"
    echo "[opencode] WARNING: Could not detect port from server output, using $OC_PORT" >&2
fi

OC_URL="http://localhost:${OC_PORT}"

# Wait until server is accepting connections (max 10s total)
_oc_ready=false
for i in $(seq 1 20); do
    if curl -sf "${OC_URL}/health" >/dev/null 2>&1 || \
       curl -sf "${OC_URL}/" >/dev/null 2>&1; then
        _oc_ready=true
        break
    fi
    sleep 0.5
done

if [[ "$_oc_ready" == false ]]; then
    echo "[opencode] WARNING: Could not confirm server readiness. Proceeding anyway." >&2
fi

echo "[opencode] Server ready at $OC_URL (pid $OC_SERVER_PID)"
echo "[opencode] Use: opencode run --attach $OC_URL --title \"...\" --model \"...\" \"...\""

export OC_PORT OC_URL OC_SERVER_PID

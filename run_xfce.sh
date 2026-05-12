#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

XVFB_WHD="${XVFB_WHD:-1366x768x24}"
XVFB_PID=""
RUN_PID=""

kill_tree() {
  local pid="$1"
  [[ -z "${pid:-}" ]] && return 0
  pkill -TERM -P "$pid" >/dev/null 2>&1 || true
  kill -TERM "$pid" >/dev/null 2>&1 || true
  sleep 1
  pkill -KILL -P "$pid" >/dev/null 2>&1 || true
  kill -KILL "$pid" >/dev/null 2>&1 || true
}

cleanup() {
  local code=$?
  trap - EXIT INT TERM HUP
  echo "[CLEANUP] Closing Dopple processes..." >&2
  kill_tree "${RUN_PID:-}"
  kill_tree "${XVFB_PID:-}"
  pkill -TERM -P $$ >/dev/null 2>&1 || true
  pkill -KILL -P $$ >/dev/null 2>&1 || true
  # Force-close project-owned browser/node leftovers only.
  pkill -TERM -f "/home/rzkz/dople/dopple_fresh_scripts" >/dev/null 2>&1 || true
  pkill -TERM -f "coinbase_cloak_auto.mjs" >/dev/null 2>&1 || true
  pkill -TERM -f "coinbase_interactive.mjs" >/dev/null 2>&1 || true
  pkill -TERM -f "quest_loop.mjs" >/dev/null 2>&1 || true
  pkill -TERM -f "quest_loop_browser.mjs" >/dev/null 2>&1 || true
  sleep 1
  pkill -KILL -f "/home/rzkz/dople/dopple_fresh_scripts" >/dev/null 2>&1 || true
  pkill -KILL -f "coinbase_cloak_auto.mjs" >/dev/null 2>&1 || true
  pkill -KILL -f "coinbase_interactive.mjs" >/dev/null 2>&1 || true
  pkill -KILL -f "quest_loop.mjs" >/dev/null 2>&1 || true
  pkill -KILL -f "quest_loop_browser.mjs" >/dev/null 2>&1 || true
  echo "[CLEANUP] Done." >&2
  exit "$code"
}
trap cleanup EXIT INT TERM HUP

if ! command -v Xvfb >/dev/null 2>&1; then
  echo "Xvfb not found" >&2
  exit 1
fi

_DISPLAY_DEFAULT=":$((90 + RANDOM % 800))"
DISPLAY_NUM="${DISPLAY_NUM:-${_DISPLAY_DEFAULT}}"
unset _DISPLAY_DEFAULT

Xvfb "$DISPLAY_NUM" -screen 0 "$XVFB_WHD" -ac -nolisten tcp >/tmp/dopple-xvfb.log 2>&1 &
XVFB_PID=$!
export DISPLAY="$DISPLAY_NUM"

# Wait for Xvfb to actually be ready (up to 10s)
for i in $(seq 1 20); do
  xdpyinfo -display "$DISPLAY_NUM" >/dev/null 2>&1 && break
  sleep 0.5
done

npm run coinbase:interactive &
RUN_PID=$!
wait "$RUN_PID"
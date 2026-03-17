#!/usr/bin/env bash
# Claude Code status line — reads JSON from stdin

input=$(cat)

# Extract model and cwd in one jq call
IFS=$'\t' read -r model cwd < <(jq -r '[.model.display_name // "", .workspace.current_dir // .cwd // ""] | @tsv' <<< "$input")

# Shorten cwd with bash parameter expansion (no subprocess)
stripped="${cwd#"$HOME"}"
[[ "$stripped" != "$cwd" ]] && short_cwd="~$stripped" || short_cwd="$cwd"

# Build display string
parts=""
[[ -n "$short_cwd" ]] && parts="$short_cwd"
[[ -n "$model" ]]     && parts="${parts}${parts:+  }${model}"

# ---------------------------------------------------------------------------
# 2x Usage Promotion
# Period    : March 13–28, 2026
# Off-peak  : outside 08:00–14:00 ET on weekdays (Mon–Fri)
# ---------------------------------------------------------------------------
promo_block=$(python3 << 'PYEOF'
from zoneinfo import ZoneInfo
import datetime, sys

tz  = ZoneInfo('America/New_York')
now = datetime.datetime.now(tz)

promo_start = datetime.datetime(2026, 3, 13,  0,  0,  0, tzinfo=tz)
promo_end   = datetime.datetime(2026, 3, 28, 23, 59, 59, tzinfo=tz)

if not (promo_start <= now <= promo_end):
    sys.exit(0)

def fmt(secs):
    h, rem = divmod(int(secs), 3600)
    m = rem // 60
    return f'{h}h {m}m' if h > 0 else f'{m}m'

is_peak = now.weekday() <= 4 and 8 <= now.hour < 14

if not is_peak:
    # Next peak boundary: next weekday 08:00 ET
    candidate = now.replace(hour=8, minute=0, second=0, microsecond=0)
    if now >= candidate:
        candidate += datetime.timedelta(days=1)
    for _ in range(7):
        if candidate.weekday() <= 4:
            break
        candidate += datetime.timedelta(days=1)
    secs = max(0, (min(candidate, promo_end) - now).total_seconds())
    countdown = fmt(secs)
    days_left = (promo_end.date() - now.date()).days + 1
    if days_left <= 3:
        suffix = ' · last day!' if days_left == 1 else f' · {days_left} days left'
        print(f'\033[33m 2x usage (ends in {countdown}{suffix})\033[0m')
    else:
        print(f'\033[32m 2x usage (ends in {countdown})\033[0m')
else:
    # Show warning only within 45 min of off-peak (14:00 ET)
    target = now.replace(hour=14, minute=0, second=0, microsecond=0)
    secs = max(0, (target - now).total_seconds())
    if secs <= 2700:
        print(f'\033[2;37m (2x starts in {fmt(secs)})\033[0m')
PYEOF
)

printf '%s%s\n' "$parts" "$promo_block"

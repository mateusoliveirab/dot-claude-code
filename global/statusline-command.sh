#!/usr/bin/env bash
# Claude Code status line — reads JSON from stdin

input=$(cat)

# Extract fields one-per-line (avoids tab-collapse bug in read with IFS=$'\t')
{
    read -r model
    read -r cwd
    read -r branch_fallback
    read -r ctx_used
    read -r cache_read
    read -r cache_write
    read -r in_tokens
    read -r out_tokens
} < <(jq -r '
    .model.display_name // "",
    (.workspace.current_dir // .cwd // ""),
    (.workspace.git_worktree // ""),
    (.context_window.used_percentage // -1 | tostring),
    (.context_window.current_usage.cache_read_input_tokens // -1 | tostring),
    (.context_window.current_usage.cache_creation_input_tokens // -1 | tostring),
    (.context_window.current_usage.input_tokens // -1 | tostring),
    (.context_window.current_usage.output_tokens // -1 | tostring)
' <<< "$input")

# Shorten cwd: replace $HOME with ~
stripped="${cwd#"$HOME"}"
[[ "$stripped" != "$cwd" ]] && short_cwd="~$stripped" || short_cwd="$cwd"

# Branch + dirty state in one git call
git_branch=""
dirty=""
if git_info=$(git --no-optional-locks -C "${cwd}" status --porcelain=v2 --branch 2>/dev/null); then
    git_branch=$(awk '/^# branch\.head/ {print $3; exit}' <<< "$git_info")
    if grep -q '^[12u?]' <<< "$git_info"; then
        dirty="*"
    fi
fi
[[ -z "$git_branch" && -n "$branch_fallback" ]] && git_branch="$branch_fallback"

# --- Left: dir + branch (cyan) ---
left=""
[[ -n "$short_cwd" ]] && left="$short_cwd"
if [[ -n "$git_branch" ]]; then
    left="${left}  \033[36m${git_branch}${dirty}\033[0m"
fi

# --- Middle: model ---
middle=""
[[ -n "$model" ]] && middle="$model"

# --- Right: ctx progress bar + tokens ---
right=""

if [[ -n "$ctx_used" && "$ctx_used" != "-1" ]]; then
    used_int=$(printf '%.0f' "$ctx_used" 2>/dev/null || echo 0)
    # Build 10-block progress bar
    filled=$(( used_int / 10 ))
    empty=$(( 10 - filled ))
    bar=""
    for (( i=0; i<filled; i++ )); do bar="${bar}▓"; done
    for (( i=0; i<empty; i++ )); do  bar="${bar}░"; done
    if (( used_int >= 90 )); then
        ctx_str="\033[31m${bar} ${used_int}%\033[0m"
    elif (( used_int >= 70 )); then
        ctx_str="\033[33m${bar} ${used_int}%\033[0m"
    else
        ctx_str="${bar} ${used_int}%"
    fi
    right="$ctx_str"
fi

# Token details — cache[hit · write] and tokens[in · out]
cache_parts=""
if [[ -n "$cache_read" && "$cache_read" != "-1" && "$cache_read" != "0" ]]; then
    cr_k=$(printf '%.1fk' "$(echo "scale=1; $cache_read/1000" | bc)")
    cache_parts="${cache_parts}${cache_parts:+ · }hit: \033[36m${cr_k}↓\033[0m"
fi
if [[ -n "$cache_write" && "$cache_write" != "-1" && "$cache_write" != "0" ]]; then
    cw_k=$(printf '%.1fk' "$(echo "scale=1; $cache_write/1000" | bc)")
    cache_parts="${cache_parts}${cache_parts:+ · }write: \033[33m${cw_k}↑\033[0m"
fi

token_parts=""
if [[ -n "$in_tokens" && "$in_tokens" != "-1" && "$in_tokens" != "0" ]]; then
    in_k=$(printf '%.1fk' "$(echo "scale=1; $in_tokens/1000" | bc)")
    token_parts="${token_parts}${token_parts:+ · }in: ${in_k}↑"
fi
if [[ -n "$out_tokens" && "$out_tokens" != "-1" && "$out_tokens" != "0" ]]; then
    out_k=$(printf '%.1fk' "$(echo "scale=1; $out_tokens/1000" | bc)")
    token_parts="${token_parts}${token_parts:+ · }out: \033[32m${out_k}↓\033[0m"
fi

combined_tokens=""
[[ -n "$cache_parts" ]]  && combined_tokens="cache[${cache_parts}]"
[[ -n "$token_parts" ]]  && combined_tokens="${combined_tokens}${combined_tokens:+  }tokens[${token_parts}]"
[[ -n "$combined_tokens" ]] && right="${right}${right:+  }${combined_tokens}"

# --- Assemble ---
line=""
[[ -n "$left" ]]   && line="$left"
[[ -n "$middle" ]] && line="${line}${line:+  }${middle}"
[[ -n "$right" ]]  && line="${line}${line:+  }${right}"

printf "%b\n" "${line}"

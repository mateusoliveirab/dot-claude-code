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

printf '%s\n' "$parts"

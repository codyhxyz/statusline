#!/usr/bin/env bash
# Deterministic simulated session for the statusline hero GIF.
# Driven by docs/demo.tape via `vhs docs/demo.tape`.
#
# Renders the same ANSI sequences that statusline-command.sh emits
# (bold model, dim labels, truecolor HSL ring, dimmer bracketed extras)
# so the GIF matches what real users see in Claude Code.

set -e

ESC=$'\033'
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
DIM="${ESC}[90m"
DIMMER="${ESC}[38;5;240m"
SEP="  ${DIM}·${RESET}  "

MODEL="${BOLD}Opus 4.7 (1M context)${RESET}"

# ring_for — mirrors statusline-command.sh
ring_for() {
  if   [ "$1" -lt 13 ]; then printf '○'
  elif [ "$1" -lt 38 ]; then printf '◔'
  elif [ "$1" -lt 63 ]; then printf '◑'
  elif [ "$1" -lt 88 ]; then printf '◕'
  else                       printf '●'
  fi
}

# HSL→RGB gradient identical to statusline-command.sh's color_for.
color_for() {
  awk -v p="$1" 'function abs(x){return x<0?-x:x}
  BEGIN {
    if (p<0) p=0; if (p>100) p=100
    h = 120 * (1 - p/100); s = 0.90; l = 0.55
    c = (1 - abs(2*l - 1)) * s
    hp = h / 60
    hm = hp - 2*int(hp/2)
    x = c * (1 - abs(hm - 1))
    if      (hp<1) { r=c; g=x; b=0 }
    else if (hp<2) { r=x; g=c; b=0 }
    else if (hp<3) { r=0; g=c; b=x }
    else if (hp<4) { r=0; g=x; b=c }
    else if (hp<5) { r=x; g=0; b=c }
    else           { r=c; g=0; b=x }
    m = l - c/2
    printf "\033[38;2;%d;%d;%dm", int((r+m)*255+0.5), int((g+m)*255+0.5), int((b+m)*255+0.5)
  }'
}

meter() {
  local label="$1" pct="$2" extra="$3"
  local c r
  c=$(color_for "$pct")
  r=$(ring_for "$pct")
  printf '%s%s%s %s%s %s%%%s %s[%s]%s' \
    "$DIM" "$label" "$RESET" \
    "$c" "$r" "$pct" "$RESET" \
    "$DIMMER" "$extra" "$RESET"
}

# line ctx_pct ctx_tok  5h_pct 5h_reset  7d_pct 7d_reset
line() {
  printf '%s  %s%s%s%s%s\n' \
    "$MODEL" \
    "$(meter 'ctx' "$1" "$2")" "$SEP" \
    "$(meter '5h'  "$3" "$4")" "$SEP" \
    "$(meter '7d'  "$5" "$6")"
}

narrate() {
  printf '%s# %s%s\n' "$DIM" "$1" "$RESET"
  sleep 0.45
}

# ----- simulated session -----

narrate "fresh session — all green"
line   4 40k    2 T-4h50m    1 T-6d22h
sleep 1.0

narrate "30 min in, a few tool calls"
line  18 180k   8 T-4h25m    3 T-6d20h
sleep 1.0

narrate "heavy tool-use burst — ctx climbing"
line  42 420k  24 T-3h12m    5 T-6d14h
sleep 1.0

narrate "half-window — amber ring takes over"
line  55 550k  32 T-2h44m    7 T-6d08h
sleep 1.0

narrate "approaching 5h cap — two meters amber"
line  68 680k  55 T-1h20m    9 T-5d22h
sleep 1.0

narrate "red zone — /clear territory"
line  88 880k  78 T-0h42m   12 T-5d10h
sleep 1.2

narrate "/clear — fresh context, limits persist"
line   3 30k   78 T-0h38m   12 T-5d09h
sleep 1.2

narrate "new session after 5h reset"
line   2 20k    1 T-4h58m   18 T-4d22h
sleep 1.0

#!/bin/sh
input=$(cat)

ESC=$(printf '\033')
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
DIM="${ESC}[90m"
DIMMER="${ESC}[38;5;240m"
SEP="  ${DIM}·${RESET}  "

ring_for() {
  if   [ "$1" -lt 13 ]; then printf '○'
  elif [ "$1" -lt 38 ]; then printf '◔'
  elif [ "$1" -lt 63 ]; then printf '◑'
  elif [ "$1" -lt 88 ]; then printf '◕'
  else                       printf '●'
  fi
}

# HSL→RGB truecolor gradient: hue 120° (green) at 0% → 0° (red) at 100%
color_for() {
  awk -v p="$1" 'function abs(x){return x<0?-x:x}
  BEGIN {
    if (p<0) p=0; if (p>100) p=100
    h = 120 * (1 - p/100)
    s = 0.90; l = 0.55
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

fmt_duration() {
  s=$1
  if [ "$s" -le 0 ];     then printf '0m'; return; fi
  if [ "$s" -lt 3600 ];  then printf '%dm' $((s/60)); return; fi
  if [ "$s" -lt 86400 ]; then printf '%dh%02dm' $((s/3600)) $(((s%3600)/60)); return; fi
  printf '%dd%02dh' $((s/86400)) $(((s%86400)/3600))
}

# label, pct, [extra]
render_meter() {
  label="$1"; pct="$2"; extra="$3"
  c=$(color_for "$pct")
  r=$(ring_for "$pct")
  out=$(printf '%s%s%s %s%s %s%%%s' "$DIM" "$label" "$RESET" "$c" "$r" "$pct" "$RESET")
  [ -n "$extra" ] && out="${out}$(printf ' %s[%s]%s' "$DIMMER" "$extra" "$RESET")"
  printf '%s' "$out"
}

model=$(echo "$input"        | jq -r '.model.display_name // "Claude"')
model_id=$(echo "$input"     | jq -r '.model.id // ""')
transcript=$(echo "$input"   | jq -r '.transcript_path // ""')
five_pct=$(echo "$input"     | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_resets=$(echo "$input"  | jq -r '.rate_limits.five_hour.resets_at // empty')
week_pct=$(echo "$input"     | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_resets=$(echo "$input"  | jq -r '.rate_limits.seven_day.resets_at // empty')

ctx_int=""; ctx_k=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  case "$model_id" in
    *"[1m]"*|*"-1m"*|*"1M"*) window=1000000 ;;
    *)                       window=200000  ;;
  esac
  ctx_tokens=$(tail -n 1000 "$transcript" 2>/dev/null | jq -s '
    map(select(.message.usage and (.isSidechain != true)))
    | if length > 0
      then last | .message.usage
        | ((.input_tokens // 0)
           + (.cache_read_input_tokens // 0)
           + (.cache_creation_input_tokens // 0))
      else empty
      end' 2>/dev/null)
  if [ -n "$ctx_tokens" ] && [ "$ctx_tokens" != "null" ]; then
    ctx_int=$(( ctx_tokens * 100 / window ))
    [ "$ctx_int" -gt 100 ] && ctx_int=100
    ctx_k="$(( (ctx_tokens + 500) / 1000 ))k"
  fi
fi

reset_str() {
  [ -n "$1" ] || return
  d=$(( $1 - $(date +%s) ))
  [ "$d" -gt 0 ] && printf 'T-%s' "$(fmt_duration "$d")"
}
five_reset_str=$(reset_str "$five_resets")
week_reset_str=$(reset_str "$week_resets")

groups=""
add_group() {
  if [ -z "$groups" ]; then groups="$1"; else groups="${groups}${SEP}$1"; fi
}
[ -n "$ctx_int" ]  && add_group "$(render_meter 'ctx' "$ctx_int" "$ctx_k")"
[ -n "$five_pct" ] && add_group "$(render_meter '5h' "$(printf '%.0f' "$five_pct")" "$five_reset_str")"
[ -n "$week_pct" ] && add_group "$(render_meter '7d' "$(printf '%.0f' "$week_pct")" "$week_reset_str")"

out=$(printf '%s%s%s  %s' "$BOLD" "$model" "$RESET" "$groups")

if [ -z "$ctx_int" ] && [ -z "$five_pct" ] && [ -z "$week_pct" ]; then
  cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
  out=$(printf '%s%s%s  %s%s%s' "$BOLD" "$model" "$RESET" "$DIM" "$(basename "$cwd")" "$RESET")
fi

printf '%s' "$out"

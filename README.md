# statusline

> My Claude Code statusline. Built around token management and context-rot prevention.

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License"></a>
  <a href="https://claude.com/product/claude-code"><img src="https://img.shields.io/badge/built_for-Claude%20Code-d97706" alt="Built for Claude Code"></a>
  <a href="https://github.com/codyhxyz/codyhxyz-plugins"><img src="https://img.shields.io/badge/part_of-codyhxyz--plugins-ffd900?logo=github&logoColor=000" alt="Part of codyhxyz-plugins"></a>
</p>

<p align="center"><img src="docs/hero.gif" alt="statusline in action — ring glyph and HSL gradient across a simulated session" width="1200"></p>

Opus 4.7 is sharp, but the new cost of sharpness is that **vague prompts burn tokens at a real clip**. So my main priority right now is aggressive context management: watch the context window, watch the session limits, dial down thinking effort when I can.

This statusline is the dashboard for that. Always on. That way I don't find out I'm hemorrhaging tokens only when Claude tells me to `/clear`.

## What it shows

```
Opus 4.7 (1M context)  ctx ◑ 42% [420k]  ·  5h ◔ 24% [T-3h12m]  ·  7d ○ 8% [T-5d14h]
```

- **`ctx`** — current context window usage (auto-detects 200k vs 1M from the model ID) with a color-graded ring (green → red) and raw token count.
- **`5h`** — Max session (5-hour) rate limit usage with a live countdown to reset.
- **`7d`** — rolling 7-day rate limit usage with a live countdown to reset.

All countdowns come straight from Claude Code's `rate_limits` payload. Nothing hard-coded, nothing to configure. The ring glyph (`○ ◔ ◑ ◕ ●`) plus a 24-bit color gradient is the point. You don't have to read the number to know you're in the red.

## Install

```bash
/plugin marketplace add codyhxyz/codyhxyz-plugins
/plugin install statusline@codyhxyz-plugins
```

See the full [codyhxyz-plugins marketplace](https://github.com/codyhxyz/codyhxyz-plugins) for my other plugins.

## How I actually manage context

The statusline is the dashboard. What I do with it:

- **Keep `/statusline` on, always.** By the time Anthropic tells you to `/clear`, you've already been paying for a bloated context for a while.
- **`/clear` early and often.** Hand context to a fresh session yourself. Cheaper than letting the current one rot.
- **Push subtasks to subagents** so the main thread stays lean without breaking flow.

That's how I run ~10 parallel Claudes on Max x20 without the wheels coming off. :L)

### Bonus: if your prompts are vague, Opus will punish you

Opus 4.7 burns real tokens on vague prompts. If you already know the prompt you're about to send is sloppy, try my [**prompt-optimizer**](https://github.com/codyhxyz/prompt-optimizer) plugin — `@prompt-optimizer` at the end does it. Burn fewer tokens, get better results.

## Requirements

- `jq` on PATH (macOS: `brew install jq`)
- A terminal that supports 24-bit truecolor (basically every modern one)

## License

MIT

---

<sub>Part of <a href="https://github.com/codyhxyz/codyhxyz-plugins"><b>codyhxyz-plugins</b></a> 🍋 — my registry of Claude Code plugins.</sub>

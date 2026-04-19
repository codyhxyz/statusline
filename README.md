# statusline

> My Claude Code statusline. Built around token management and context-rot prevention.

<p align="center"><img src="docs/hero.gif" alt="statusline in action — ring glyph and HSL gradient across a simulated session" width="1200"></p>

Opus 4.7 is sharp, but the new cost of sharpness is that **prompts have to be more explicit or it burns tokens at a real clip**. So my main priority right now is aggressive context management: keeping an eye on the context window, keeping an eye on session limits, and reducing thinking effort when and where possible.

This statusline is one piece of that system — persistent, at-a-glance awareness so I don't find out I'm hemorrhaging tokens only when Claude tells me to `/clear`.

## What it shows

```
Opus 4.7 (1M context)  ctx ◑ 42% [420k]  ·  5h ◔ 24% [T-3h12m]  ·  7d ○ 8% [T-5d14h]
```

- **`ctx`** — current context window usage (auto-detects 200k vs 1M window from the model ID) with a color-graded ring (green → red) and raw token count.
- **`5h`** — Max session (5-hour) rate limit usage with live countdown to reset.
- **`7d`** — rolling 7-day rate limit usage with live countdown to reset.

All countdowns pull from Claude Code's own `rate_limits` payload — nothing hard-coded, nothing to configure. The ring glyph (`○ ◔ ◑ ◕ ●`) + HSL truecolor gradient makes the severity pre-attentive — you don't have to read the number to know you're in the red.

## Install

```bash
/plugin marketplace add codyhxyz/codyhxyz-plugins
/plugin install statusline@codyhxyz-plugins
```

## How I actually manage context

The statusline is just the dashboard. The real workflow:

- **`/statusline` on, always** — persistent awareness beats reactive `/clear`. By the time Anthropic tells you to clear, you've already been burning tokens on a bloated context for a while.
- **`/clear` early and often** — pass context manually to a fresh session. Cheaper than letting the current one rot.
- **Subagents to pare down context** for specific subtasks — keeps the main thread lean without breaking flow.

This is what lets me run ~10 parallel Claudes on Max x20 without the wheels coming off. :L)

### Bonus: if your prompts are vague, Opus will punish you

Now that Opus 4.7 burns real tokens on vague prompts, you may want to consider trying my [**prompt-optimizer**](https://github.com/codyhxyz/prompt-optimizer) plugin.

Just `@prompt-optimizer` at the end of a prompt you know is vague. Burn fewer tokens, get better results.

## Requirements

- `jq` on PATH (macOS: `brew install jq`)
- A terminal that supports 24-bit truecolor (pretty much all modern ones)

## License

MIT

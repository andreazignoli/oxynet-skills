# Oxynet skills

Teaches AI coding agents to analyse cardiopulmonary exercise tests (CPET) with
[Oxynet](https://www.oxynet.net), over its REST API. No MCP connector is needed: the agent
uploads the vendor file, receives a handle, and asks for the analyses by name.

One skill, packaged for several tools:

- **Agent Skill** (`skills/`), the open format read by Claude Code, Gemini CLI, OpenAI Codex,
  Cursor, GitHub Copilot and others
- **Claude Code plugin marketplace** (`.claude-plugin/`)
- **Gemini CLI extension** (`gemini-extension.json`)

**Status: in preparation. Nothing here is installable yet.**

## What Oxynet does

Oxynet reads the raw export of a metabolic cart, detects the format, and returns
ventilatory thresholds (VT1 and VT2), substrate use (fat and carbohydrate oxidation,
FATMAX), exercise oscillatory ventilation and signal-quality checks as structured,
versioned JSON. The assistant routes the question and explains the answer; Oxynet's
validated models decide the physiology.

Research software, not a diagnostic device. Results carry no confidence score, because
nothing is calibrated against clinical outcomes. Oscillatory ventilation analysis is beta:
it was developed on one heart failure cohort and its transportability is untested.

## Links

- Agent guide: https://app.oxynet.net/llms.txt
- Full agent guide: https://app.oxynet.net/llms-full.txt
- OpenAPI schema: https://app.oxynet.net/v1/openapi.json
- Developer docs: https://www.oxynet.net/developers

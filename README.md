# Oxynet skills

Teaches AI coding agents to analyse cardiopulmonary exercise tests (CPET) with
[Oxynet](https://www.oxynet.net), over its REST API. No MCP connector is needed: the agent
uploads the vendor file, receives a handle, and asks for the analyses by name.

One skill, [`skills/oxynet-cpet/SKILL.md`](skills/oxynet-cpet/SKILL.md), packaged for
several tools:

| Tool | How it is packaged |
|---|---|
| Claude Code | Plugin marketplace (`.claude-plugin/`) |
| Gemini CLI | Extension (`gemini-extension.json`) |
| OpenAI Codex, Cursor, GitHub Copilot and others | The Agent Skills format the skill is written in |

## Install

You need an Oxynet API key, available to the agent as the `OXYNET_API_KEY` environment
variable (for example in your shell profile). Keys are issued on request:
[www.oxynet.net/developers/quickstart](https://www.oxynet.net/developers/quickstart).

**Claude Code**

```
/plugin marketplace add andreazignoli/oxynet-skills
/plugin install oxynet@oxynet
```

**Gemini CLI**

```
gemini extensions install https://github.com/andreazignoli/oxynet-skills
```

**Any tool that reads Agent Skills:** copy `skills/oxynet-cpet/` into that tool's skills
directory.

Then hand the agent a CPET export and ask for what you need: "what are the ventilatory
thresholds in `tests/athlete_03.xlsx`?"

## What Oxynet does

Oxynet reads the raw export of a metabolic cart, detects the format, and returns
ventilatory thresholds (VT1 and VT2), substrate use (fat and carbohydrate oxidation,
FATMAX), exercise oscillatory ventilation and signal-quality checks as structured,
versioned JSON. The assistant routes the question and explains the answer; Oxynet's
validated models decide the physiology.

Research software, not a diagnostic device. Results carry no confidence score, because
nothing is calibrated against clinical outcomes. Oscillatory ventilation analysis is beta:
it was developed on one heart failure cohort and its transportability is untested.

The agent sends the file you name and nothing else. Oxynet parses the bytes and discards
them, and deletes the parsed record after 24 hours. It needs no patient identifiers, so
anonymise a name or a date of birth before uploading.

## License

Apache License 2.0 ([LICENSE](LICENSE), [NOTICE](NOTICE)). Use, copy and adapt the skill
freely; the license grants no right to the Oxynet name, and using the Oxynet API requires a
key and is subject to its own terms.

## Links

- Agent guide: https://app.oxynet.net/llms.txt
- Full agent guide: https://app.oxynet.net/llms-full.txt
- OpenAPI schema: https://app.oxynet.net/v1/openapi.json
- Developer docs: https://www.oxynet.net/developers
- MCP server, for assistants that prefer a connector: https://app.oxynet.net/oxynet-mcp

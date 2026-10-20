# Oxynet skills

Teaches AI agents to analyse cardiopulmonary exercise tests (CPET) with
[Oxynet](https://www.oxynet.net): the agent hands Oxynet the vendor file, receives a handle,
and asks for the analyses by name. Oxynet's validated models compute the physiology.

| Tool | What to install | How it reaches Oxynet |
|---|---|---|
| Claude Code, Claude chat, Cowork | The plugin in [`claude/`](claude/) | The Oxynet MCP server; you sign in once with your key |
| Gemini CLI | The extension (`gemini-extension.json`) | REST with curl, key in `OXYNET_API_KEY` |
| OpenAI Codex, Cursor, GitHub Copilot and others | The skill in [`skills/oxynet-cpet/`](skills/oxynet-cpet/SKILL.md) | REST with curl, key in `OXYNET_API_KEY` |

You need an Oxynet API key. Get a free one at
[app.oxynet.net/signup](https://app.oxynet.net/signup): the page also gives you, for your
system, the one command that saves it as `OXYNET_API_KEY`.

## Install

**Claude Code**

```
/plugin marketplace add andreazignoli/oxynet-skills
/plugin install oxynet@oxynet
```

Then run `/mcp`, choose `oxynet` and sign in: Oxynet's page asks for your key once. No
environment variable is needed. If you already added Oxynet as a connector on claude.ai,
Claude Code uses that connector instead and lists no separate `oxynet` server: sign in
there (claude.ai, Settings, Connectors) and the plugin's skill uses its tools.

**Gemini CLI**

```
gemini extensions install https://github.com/andreazignoli/oxynet-skills
```

**Any tool that reads Agent Skills:** copy `skills/oxynet-cpet/` into that tool's skills
directory.

Then hand the agent a CPET export and ask for what you need: "what are the ventilatory
thresholds in `tests/athlete_03.xlsx`?" The agent asks you before each call that sends a file
to Oxynet. That is expected: it is the moment you decide that a file leaves your computer.

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
freely. If you redistribute it, modified or not, keep the attribution in [NOTICE](NOTICE):
section 4(d) of the license requires it. The license grants no right to the Oxynet name,
and using the Oxynet API requires a key and is subject to its own
[terms](https://www.oxynet.net/terms).

## Links

- Agent guide: https://app.oxynet.net/llms.txt
- Full agent guide: https://app.oxynet.net/llms-full.txt
- OpenAPI schema: https://app.oxynet.net/v1/openapi.json
- Developer docs: https://www.oxynet.net/developers
- MCP server, for assistants that prefer a connector: https://app.oxynet.net/oxynet-mcp
  (in claude.ai and Claude Desktop, Oxynet is in Claude's connector directory:
  https://claude.ai/directory/oxynet)

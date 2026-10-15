# oxynet-skills

What teaches a coding agent to use Oxynet without an MCP connector. It holds one Agent
Skill and the manifests that package it for each tool. It contains no product code: the
API it describes lives in `../oxynet-core`, and the orchestration repo (`..`) holds the
cross-repo rules, which apply here too (no em dashes in anything an agent or a user reads,
no confidence percentage, sell measurement rather than AI, the oscillation beta caveat
wherever oscillation is mentioned).

Created 2026-10-15, private until the first skill ships, then public. It was kept apart
from `pyoxynet` on purpose, so the package can be reworked on its own schedule and a
plugin install does not clone the package's 200 MB of history.

## Intended layout (not built yet)

```
skills/oxynet-cpet/SKILL.md       the skill, Agent Skills open standard (agentskills.io)
.claude-plugin/marketplace.json   Claude Code marketplace, one plugin whose source is "./"
.claude-plugin/plugin.json        the plugin: the skill, optionally the remote MCP server
gemini-extension.json             Gemini CLI extension. Must be at the repo root to be indexed
```

To verify before building: where a Gemini CLI extension expects its skills, and whether
one `skills/` folder can serve both the Claude plugin and the Gemini extension.

## Rules for the skill

1. **State rules, link the details.** The skill says how to work with Oxynet (upload the
   vendor file unchanged, work by `cpet_id`, report a refusal instead of working around it,
   demonstrate on `/v1/sample` rather than a patient file, never estimate a threshold from
   the trace). Everything about endpoints, formats and fields is read at run time from
   `https://app.oxynet.net/llms-full.txt`, `/v1/capabilities` and `/v1/formats`. A skill
   that restates the API goes stale the first time core changes.
2. **No number a reader can check.** Not the format count, not a model list, not a quota.
   They come from the API. The orchestration repo's registry rule applies.
3. **The key comes from `OXYNET_API_KEY`.** Never write it into a file, a logged command or
   a reply.
4. **The description decides when the skill fires.** Name and description are all the
   agent sees until a task matches, and Claude Code truncates description plus
   `when_to_use` at 1,536 characters. Lead with the use case: a CPET or metabolic cart
   export, ventilatory thresholds, VO2max, FATMAX, oscillatory ventilation.

## Before making the repo public

- Choose a licence.
- Test the skill in Claude Code and Gemini CLI on `/v1/sample`, and check that it fires
  from the description alone (`claude plugin eval` for Claude Code).
- Add the `gemini-cli-extension` GitHub topic (the Gemini gallery indexes tagged public
  repos daily; there is nothing to submit).
- Submit the plugin to Anthropic's directory at claude.ai/directory/manage.

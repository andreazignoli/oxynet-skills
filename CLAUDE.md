# oxynet-skills

What teaches a coding agent to use Oxynet without an MCP connector. It holds one Agent
Skill and the manifests that package it for each tool. It contains no product code: the
API it describes lives in `../oxynet-core`, and the orchestration repo (`..`) holds the
cross-repo rules, which apply here too (no em dashes in anything an agent or a user reads,
no confidence percentage, sell measurement rather than AI, the oscillation beta caveat
wherever oscillation is mentioned).

Created 2026-10-15, private until it is made public on purpose. It was kept apart from
`pyoxynet` so the package can be reworked on its own schedule and a plugin install does
not clone the package's 200 MB of history.

## Layout

```
skills/oxynet-cpet/SKILL.md       the skill, Agent Skills open standard (agentskills.io)
.claude-plugin/marketplace.json   Claude Code marketplace "oxynet", one plugin whose source is "./"
.claude-plugin/plugin.json        the plugin "oxynet"; skills/ is discovered, not declared
gemini-extension.json             Gemini CLI extension; it discovers skills/ on its own
```

The repo root is the plugin root, so everything here is copied into a user's plugin cache.
Keep it to the skill and its manifests.

`claude plugin validate .` passes. With `--strict` it fails on one warning, that this
CLAUDE.md is not loaded as plugin context. That is expected: this file is for sessions
working on the repo, not for the people who install the plugin.

## Rules for the skill

1. **State rules, link the details.** The skill says how to work with Oxynet (upload the
   vendor file unchanged, work by `cpet_id`, report a refusal instead of working around it,
   demonstrate on `/v1/sample` rather than a patient file, never estimate a threshold from
   the trace). Fields, error codes and formats are read at run time from
   `https://app.oxynet.net/llms-full.txt`, `/v1/capabilities` and `/v1/metrics`. A skill
   that restates the API goes stale the first time core changes.
2. **No number a reader can check.** Not the format count, not a model list, not a quota.
   They come from the API. The orchestration repo's registry rule applies.
3. **The key comes from `OXYNET_API_KEY`.** Never write it into a file, a logged command or
   a reply. The skill pre-approves no tools (`allowed-tools` is deliberately absent): the
   user's own permission settings decide whether a file may be sent.
4. **Every command is self-contained**, because shell variables do not survive between an
   agent's commands. That is why each one repeats the base URL expression.
5. **The User-Agent is `oxynet-skill/<n>`.** Core's telemetry classes it as `skill`
   (`oxynet/api/telemetry.py`), which is how skill traffic is told apart from any other
   curl. Keep it on every command, and bump `<n>` only if the skill's behaviour changes in
   a way worth counting separately.
6. **The description decides when the skill fires.** Name and description are all the
   agent sees until a task matches, and Claude Code truncates description plus
   `when_to_use` at 1,536 characters. Lead with the use case.

## Testing against a local server

`OXYNET_API_URL` exists so the skill can be exercised without touching production. From
`../oxynet-core`, start a server with a throwaway key, then run each command in SKILL.md
with `OXYNET_API_URL=http://127.0.0.1:8765` and `OXYNET_API_KEY=sk_test_skilllocal0001`:

```bash
OXYNET_ROOT=. OXYNET_ADMIN_KEY=local-dummy \
OXYNET_API_KEYS='{"sk_test_skilllocal0001": {"name": "skill-local-test", "tier": "free", "products": ["*"]}}' \
uv run oxynet-serve --host 127.0.0.1 --port 8765
```

Use only the synthetic sample (save `/v1/sample`'s `content` to a file to test the
multipart upload). Afterwards delete what the run wrote: core's `telemetry/`, and
`cpet/<tenant>` and `usage/<month>/<tenant>` for the test key's tenant.

First run, 2026-10-15: every command worked except the sample pipe, which exposed a core
bug (`/v1/cpet/content` refused the sample's `content` object; fixed in oxynet-core PR #11).
The skill converts it with `tojson`, which works before and after that fix.

## Before making the repo public

- Choose a licence (none is declared yet, in the repo or in `plugin.json`).
- Check that the skill fires from its description alone in Claude Code (`claude plugin eval`)
  and in Gemini CLI.
- Add the `gemini-cli-extension` GitHub topic (the Gemini gallery indexes tagged public
  repos daily; there is nothing to submit).
- Submit the plugin to Anthropic's directory at claude.ai/directory/manage.

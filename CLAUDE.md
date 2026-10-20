# oxynet-skills

What teaches a coding agent to use Oxynet without an MCP connector. It holds one Agent
Skill and the manifests that package it for each tool. It contains no product code: the
API it describes lives in `../oxynet-core`, and the orchestration repo (`..`) holds the
cross-repo rules, which apply here too (no em dashes in anything an agent or a user reads,
no confidence percentage, sell measurement rather than AI, the oscillation beta caveat
wherever oscillation is mentioned).

Created 2026-10-15, public since 2026-10-19 (the founder's decision). It was kept apart from
`pyoxynet` so the package can be reworked on its own schedule and a plugin install does
not clone the package's 200 MB of history.

## Layout

```
claude/                           the Claude plugin (directory submission: plugin path "claude")
  .claude-plugin/plugin.json      name "oxynet", listing fields (icon, privacy, terms, support)
  .mcp.json                       the remote MCP server, no credential: the user signs in by OAuth
  skills/oxynet-cpet/SKILL.md     the MCP variant of the skill: rules, tool names, no curl
  README.md, LICENSE, NOTICE      copies of LICENSE and NOTICE: an install receives this folder only
  icon.svg                        the app's mark in Oxynet green on the app's dark ground
openai/                           the ChatGPT and Codex plugin (OpenAI portable format), zipped for upload
  plugin.json                     identity + extensions.com.openai: listing, 5+3 review cases, release notes
  mcp.json                        the remote MCP server, OAuth by dynamic client registration
  skills/oxynet-cpet/SKILL.md     the MCP variant again, with ChatGPT's sign-in paragraph
  assets/logo.png, icon.png       512 and 256 px renders of claude/icon.svg
  README.md, LICENSE, NOTICE      as in claude/
scripts/package-openai.sh         checks the copies match, writes dist/oxynet-openai-<version>.zip
skills/oxynet-cpet/SKILL.md       the curl variant, for Gemini CLI, Codex and any Agent Skills tool
.claude-plugin/marketplace.json   Claude Code marketplace "oxynet", one plugin, source "./claude"
gemini-extension.json             Gemini CLI extension at the root; it discovers skills/ on its own
```

**Two variants of one skill, on purpose (2026-10-19).** Anthropic's directory holds for a
reviewer any plugin that reads a credential from the user's environment (`$OXYNET_API_KEY`)
and sends it to a server, and a plugin's own sensitive `userConfig` value is not substituted
into skill text, so the curl route cannot work inside a Claude plugin. The plugin therefore
declares the MCP server without any credential and the user signs in once through Oxynet's
OAuth page, which also makes it work in claude.ai chat and Cowork, where there is no shell.
The root skill keeps the curl route for tools without MCP sign-in. When a rule changes,
change it in all three `SKILL.md` files (root, `claude/`, `openai/`); the `## Rules` sections of
`claude/` and `openai/` must be identical, and `LICENSE` and `NOTICE` in both folders must stay
byte-identical to the root ones. `scripts/package-openai.sh` refuses to build otherwise.

**The OpenAI package (2026-10-20).** OpenAI's portable format puts `plugin.json` at the ZIP root,
with listing fields, review test cases and release notes under `extensions.com.openai`; the
upload at platform.openai.com/plugins imports them. Reviewer credentials and the demo video URL
are entered in the dashboard, never in the package (`test_credentials` is rejected). The OAuth
declaration sits in `mcp.json` under the server's `extensions.com.openai.auth`, as OpenAI's docs
show, although the public agent-plugins.org 1.0.0 schema does not allow it there; if an upload
refuses it, delete the block, since the server advertises DCR by discovery anyway. Category is
Education & Research, not Healthcare, matching the research-only terms. `brandColor` is the
registry's gradient blue because the Oxynet green fails OpenAI's 2:1 contrast on white (1.8).
The expected results in the review cases were run against a local server on 2026-10-20.

**A claude.ai Oxynet connector hides the plugin's server.** Claude Code suppresses a plugin
MCP server whose URL duplicates a claude.ai connector (its debug log: "Lazy dedup:
suppressing 1 plugin server(s) that duplicate claude.ai connectors"), so for someone with
both, `/mcp` lists no `oxynet` and the connector's tools serve the skill. Sign-in then
happens on claude.ai. Both READMEs and the skill say so (found 2026-10-19, the founder's
first install). Signing in from Claude Code needs core v67 or later: before it the server
never answered 401, so Claude Code saw it as connected and offered no sign-in.

`claude plugin validate .` (marketplace) and `claude plugin validate ./claude --strict` pass.
CLAUDE.md is at the repo root, outside the plugin folder, so it no longer draws the
"not loaded as plugin context" warning.

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

## Public, and the directories

Public since 2026-10-19 under Apache-2.0, with the `gemini-cli-extension` topic, so the Gemini
CLI gallery indexes it on its own. Checked first: the skill fires from its description alone
(a headless Claude Code session, prompt not naming Oxynet, first action
`Skill: oxynet:oxynet-cpet`), and the history holds no secret.

The MCP server is **published in Anthropic's Connectors Directory** (2026-10-20), submitted
as an **MCP connector** from the founder's own account; the texts as sent are in the
orchestration repo, `docs/listings/anthropic-directory.md`. The plugin follows from
claude.ai/directory/manage as a **Plugin bundle**, repository `andreazignoli/oxynet-skills`,
plugin path `claude`. A plugin may connect to any connector approved in the directory, so the
listing also clears the plugin's one MCP server.

The plugin bundle was submitted 2026-10-20, tracking `main`. A GitHub push webhook (push events
only, JSON, secret held by GitHub) notifies the directory, so **every merge to `main` is
picked up and scanned as a new version**: run both `claude plugin validate` commands before
merging. A lost webhook secret is replaced with Rotate secret on the plugin's Settings tab
at claude.ai/directory/manage.

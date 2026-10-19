# Oxynet for Claude

Analyse cardiopulmonary exercise tests (CPET) with [Oxynet](https://www.oxynet.net) from
Claude Code, Claude chat and Cowork. Hand Claude a metabolic cart export and ask for what you
need: ventilatory thresholds (VT1 and VT2), substrate use (fat and carbohydrate oxidation,
FATMAX), exercise oscillatory ventilation, or the quality of the recording. Claude routes the
question and explains the answer; Oxynet's validated models compute the physiology.

Research software, not a diagnostic device. Results carry no confidence score, because
nothing is calibrated against clinical outcomes. Oscillatory ventilation analysis is beta:
it was developed on one heart failure cohort and its transportability is untested.

## What this plugin contains

- A connection to the Oxynet MCP server at `https://app.oxynet.net/oxynet-mcp`.
- A skill (`oxynet-cpet`) that tells Claude when to use it and the rules to follow.

It runs no code on your computer and stores no credential.

## Signing in

The first time Claude uses Oxynet, you sign in once: in Claude Code run `/mcp`, choose
`oxynet`, and paste your Oxynet API key on Oxynet's sign-in page. Get a free key at
[app.oxynet.net/signup](https://app.oxynet.net/signup).

## What it sends, and where

- **Only the files you name**, unchanged, to Oxynet at `app.oxynet.net` over HTTPS. Claude
  asks before each upload. Remove names and dates of birth from an export first: Oxynet
  needs no patient identifiers.
- Oxynet reads each file and discards it, keeps the parsed recording for 24 hours so you can
  analyse it, and never uses uploads to train its models. Results come back to Claude.
- Nothing is sent anywhere else. See the [privacy policy](https://www.oxynet.net/privacy)
  and the [terms of use](https://www.oxynet.net/terms).

## License

Apache License 2.0 ([LICENSE](LICENSE), [NOTICE](NOTICE)). If you redistribute this plugin,
keep the attribution in NOTICE.

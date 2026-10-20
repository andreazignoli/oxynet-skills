---
name: oxynet-cpet
description: Analyse cardiopulmonary exercise test (CPET) files with Oxynet. Use when the user has a metabolic cart export (COSMED, Cortex, PNOE, VO2 Master and other formats, as CSV, XLSX, TXT, XML or JSON) or asks for ventilatory thresholds (VT1, VT2, GET, RCP), VO2max, the VE/VCO2 slope, FATMAX or fat and carbohydrate oxidation, exercise oscillatory ventilation, or the signal quality of a CPET recording. Oxynet's validated models compute the physiology through the Oxynet tools this plugin connects; do not estimate thresholds from the trace yourself.
license: Apache-2.0
---

# CPET analysis with Oxynet

This plugin connects the Oxynet MCP server. Its tools do the work: you orchestrate and
explain, Oxynet's validated models decide the physiology. The server's own instructions
describe each tool in detail; this file states the rules.

If the Oxynet tools are not available yet, the user connects Oxynet once from the plugin and
signs in on Oxynet's page with their Oxynet API key. Someone without a key can get a free one
at https://app.oxynet.net/signup.

## Rules

1. **Start with `get_capabilities`** and tell the user which analyses their key includes.
2. **Hand Oxynet the file exactly as exported.** Do not open it, parse it, rename columns or
   convert units. For a file on disk, `create_upload` returns a one-time link to send it to;
   with the contents already in hand, `upload_cpet`. Either way you get a `cpet_id`.
3. **Only upload a file the user named.** Never search their disk for CPET files. A CPET is
   health data and exports often carry the patient's name. Before the first upload, say
   once: Oxynet needs no patient identifiers, so anonymise a name or date of birth first.
4. **Work by handle.** Never read the recording into the conversation. `get_cpet_series`
   is for drawing a picture, never for computing something Oxynet can compute.
5. **Ask for the smallest thing that answers the question.** `analyze_cpet` takes `vt`,
   `eov` and `substrate`; `compute_metrics` with `substrate_summary` answers "what is
   their FATMAX" at a fraction of the cost. Each analysis spends one of the key's monthly
   allowance.
6. **A refusal is the answer.** `not_analysable`, `unavailable` or an error code states why;
   report that reason instead of working around it.
7. **There is no confidence score.** Nothing is calibrated against clinical outcomes, so
   never invent one. `quality` describes the recording, not the certainty of the answer.
8. **Oscillatory ventilation (`eov`) is beta**: developed on one heart failure cohort,
   transportability untested. Say so whenever you report it.
9. **Research software, not a diagnosis.** Report measurements, not clinical conclusions.

To show what Oxynet does without patient data, use `get_sample_cpet`. Recordings are
deleted after 24 hours; `delete_cpet` removes one sooner.

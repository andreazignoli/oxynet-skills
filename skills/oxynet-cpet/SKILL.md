---
name: oxynet-cpet
description: Analyse cardiopulmonary exercise test (CPET) files with Oxynet's hosted API. Use when the user has a metabolic cart export (COSMED, Cortex, PNOE, VO2 Master and other formats, as CSV, XLSX, TXT, XML or JSON) or asks for ventilatory thresholds (VT1, VT2, GET, RCP), VO2max, the VE/VCO2 slope, FATMAX or fat and carbohydrate oxidation, exercise oscillatory ventilation, or the signal quality of a CPET recording. Oxynet's validated models compute the physiology; do not estimate thresholds from the trace yourself. Needs an Oxynet API key in OXYNET_API_KEY.
license: Apache-2.0
---

# CPET analysis with Oxynet

Oxynet is a hosted computation service for cardiopulmonary exercise tests. You send it
the vendor file, it returns a handle (`cpet_id`), and you ask for analyses by name. You
orchestrate and explain; Oxynet's validated models decide the physiology.

If an Oxynet MCP connector is already available in this session (tools such as
`analyze_vt`), use it instead and ignore the rest of this file.

Every command below is self-contained, because shell variables may not survive between
your commands. `OXYNET_API_URL` is only for testing against another server; leave it unset.

## 1. The key

If `OXYNET_API_KEY` is not set, ask the user to make it available as that environment
variable (for example in their shell profile) rather than pasting it into the
conversation. If they paste it anyway, use it for this session only: never write it into a
file and never repeat it back. Someone without a key can get a free one at
https://app.oxynet.net/signup (it takes a minute).

Check what the key may do, and tell the user which analyses it includes:

```bash
curl -s -A oxynet-skill/1 -H "X-API-Key: $OXYNET_API_KEY" \
  "${OXYNET_API_URL:-https://app.oxynet.net}/v1/capabilities"
```

## 2. Rules

1. **Upload the file exactly as exported.** Do not open it, parse it, rename columns or
   convert units. Oxynet detects the format and knows each one's units and clock quirks;
   converting first is how information gets lost.
2. **Only upload a file the user named.** Never search their disk for CPET files. A CPET is
   health data and exports often carry the patient's name. Before the first upload, say
   once: Oxynet needs no patient identifiers, so anonymise a name or date of birth first.
3. **Work by handle.** Never read the recording into the conversation. Fetch a series only
   to draw a picture, never to compute something Oxynet can compute.
4. **Ask for the smallest thing that answers the question.** One analysis you need beats
   three you are curious about.
5. **A refusal is the answer.** `not_analysable`, `unavailable` or an error code states
   why; report that reason instead of working around it. The one exception is
   `UNSUPPORTED_FORMAT`, whose `recovery` block says exactly what conversion is allowed.
6. **There is no confidence score.** Nothing is calibrated against clinical outcomes, so
   never invent one. `quality` describes the recording, not the certainty of the answer.
7. **Oscillatory ventilation (`eov`) is beta**: developed on one heart failure cohort,
   transportability untested. Say so whenever you report it.
8. **Research software, not a diagnosis.** Report measurements, not clinical conclusions.

## 3. Upload

One file:

```bash
curl -s -A oxynet-skill/1 -H "X-API-Key: $OXYNET_API_KEY" \
  -F "file=@path/to/export.xlsx" \
  "${OXYNET_API_URL:-https://app.oxynet.net}/v1/cpet" | jq '{cpet_id, source, flags}'
```

Several files, in one command, printing each file's handle or refusal code:

```bash
for f in path/to/folder/*.csv; do
  printf '%s\t' "$f"
  curl -s -A oxynet-skill/1 -H "X-API-Key: $OXYNET_API_KEY" -F "file=@$f" \
    "${OXYNET_API_URL:-https://app.oxynet.net}/v1/cpet" | jq -r '.cpet_id // .error'
done
```

To demonstrate Oxynet without patient data, upload the synthetic sample instead:

```bash
curl -s "${OXYNET_API_URL:-https://app.oxynet.net}/v1/sample" \
  | jq '{filename, content: (.content | tojson)}' \
  | curl -s -A oxynet-skill/1 -H "X-API-Key: $OXYNET_API_KEY" \
      -H 'Content-Type: application/json' -d @- \
      "${OXYNET_API_URL:-https://app.oxynet.net}/v1/cpet/content" | jq -r .cpet_id
```

## 4. Analyse

```bash
curl -s -A oxynet-skill/1 -H "X-API-Key: $OXYNET_API_KEY" \
  -H 'Content-Type: application/json' -d '{"analyses": ["vt"]}' \
  "${OXYNET_API_URL:-https://app.oxynet.net}/v1/cpet/CPET_ID/analyze"
```

`analyses` takes `vt` (ventilatory thresholds VT1 and VT2), `eov` (oscillatory ventilation,
beta) and `substrate` (fat and carbohydrate oxidation, FATMAX, the crossover). Each result
carries `status`, `quality`, `notes` and `provenance` beside its `findings`.

Smaller questions go to `compute`, which is cheaper: `substrate_summary` answers "what is
their FATMAX" at a fraction of the full analysis, and `gas_quality`, `sampling_adequacy`,
`clock_integrity` and `phases` describe the recording itself.

```bash
curl -s -A oxynet-skill/1 -H "X-API-Key: $OXYNET_API_KEY" \
  -H 'Content-Type: application/json' -d '{"metrics": ["substrate_summary"]}' \
  "${OXYNET_API_URL:-https://app.oxynet.net}/v1/cpet/CPET_ID/compute"
```

`GET /v1/metrics` lists every metric with its units and requirements.

## 5. Report

Give the values Oxynet returned, with their units, and quote `notes` when they qualify a
result. Say which analyses were refused and why. For a cohort, build the comparison table
yourself from the returned numbers: that is your job; deciding where a threshold is, or
whether an oscillation is real, is not.

Records are deleted after 24 hours. If the user wants one gone sooner:
`curl -s -X DELETE -A oxynet-skill/1 -H "X-API-Key: $OXYNET_API_KEY" "${OXYNET_API_URL:-https://app.oxynet.net}/v1/cpet/CPET_ID"`.

## More

Everything else (fields, error codes, formats, upload tickets, series for plotting) is in
https://app.oxynet.net/llms-full.txt. Read the relevant section rather than guessing an
endpoint or a field name.

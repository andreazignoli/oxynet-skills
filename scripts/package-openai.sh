#!/usr/bin/env bash
# Builds the ZIP uploaded at platform.openai.com/plugins (ChatGPT and Codex).
# The ZIP holds the CONTENTS of openai/, with plugin.json at its root, as
# OpenAI's portable plugin format requires. Writes dist/oxynet-openai-<version>.zip.
#
#   scripts/package-openai.sh
set -euo pipefail
cd "$(dirname "$0")/.."

cmp -s LICENSE openai/LICENSE && cmp -s NOTICE openai/NOTICE || {
  echo "openai/LICENSE or openai/NOTICE differs from the root copy: copy them again." >&2
  exit 1; }
diff -q <(sed -n '/^## Rules/,$p' claude/skills/oxynet-cpet/SKILL.md) \
        <(sed -n '/^## Rules/,$p' openai/skills/oxynet-cpet/SKILL.md) >/dev/null || {
  echo "The rules in openai/ and claude/ SKILL.md differ: change both." >&2
  exit 1; }
for f in openai/plugin.json openai/mcp.json; do
  python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$f"
done

version=$(python3 -c "import json; print(json.load(open('openai/plugin.json'))['version'])")
out="dist/oxynet-openai-$version.zip"
mkdir -p dist
rm -f "$out"
(cd openai && zip -q -r -X "../$out" . -x '.DS_Store' '*/.DS_Store')
echo "$out"
unzip -l "$out" | tail -n +4 | sed '$d' | sed '$d' | awk '{print "  " $4}'

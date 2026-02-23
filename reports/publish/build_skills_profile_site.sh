#!/usr/bin/env bash
set -euo pipefail

REPO="/Users/leskneebone/Projects/skills-SPARQL"
COMBINED="$REPO/snippets/combined"
PUBLISH_DIR="$REPO/reports/publish"
STAGE="$PUBLISH_DIR/skills-profile-site"

echo "==> Repo: $REPO"
echo "==> Working dir: $COMBINED"

cd "$COMBINED"

# Prefer 'pylode' if available; fallback to python module invocation.
if command -v pylode >/dev/null 2>&1; then
  PYLODE_CMD=(pylode)
else
  PYLODE_CMD=(python3 -m pylode)
fi

echo "==> Regenerating pyLODE outputs..."

# Explicit mapping you confirmed:
#   skills-schema.ttl   -> skills-schema.html
#   profile-header.ttl  -> skills-profile.html
#   scheme-nst*.ttl     -> scheme-nst*.html

# 1) Schema
"${PYLODE_CMD[@]}" -p vocpub skills-schema.ttl -o skills-schema.html

# 2) Profile
"${PYLODE_CMD[@]}" -p vocpub profile-header.ttl -o skills-profile.html

# 3) Schemes (only for files that actually exist)
shopt -s nullglob
scheme_ttls=(scheme-nst*.ttl)
if (( ${#scheme_ttls[@]} )); then
  for ttl in "${scheme_ttls[@]}"; do
    html="${ttl%.ttl}.html"
    "${PYLODE_CMD[@]}" -p vocpub "$ttl" -o "$html"
  done
else
  echo "WARN: No scheme-nst*.ttl files found; skipping scheme pages."
fi
shopt -u nullglob

echo "==> Staging publish site into: $STAGE"
rm -rf "$STAGE"
mkdir -p "$STAGE"

# Curated/manual pages (copy if present)
for f in skills-docs-index.html diagram.html nst-profile-architecture.svg; do
  if [[ -f "$f" ]]; then
    cp -p "$f" "$STAGE"/
  else
    echo "WARN: missing $COMBINED/$f (skipping)"
  fi
done

# Required pyLODE outputs
for f in skills-profile.html skills-schema.html; do
  if [[ -f "$f" ]]; then
    cp -p "$f" "$STAGE"/
  else
    echo "ERROR: expected output missing: $COMBINED/$f"
    exit 1
  fi
done

# Scheme HTML pages (if any)
shopt -s nullglob
scheme_pages=(scheme-nst*.html)
if (( ${#scheme_pages[@]} )); then
  cp -p scheme-nst*.html "$STAGE"/
else
  echo "WARN: no scheme-nst*.html files found to stage"
fi
shopt -u nullglob

# Manifest
( cd "$STAGE" && ls -1 ) > "$STAGE/manifest.txt"

echo "==> Creating zip: $PUBLISH_DIR/skills-profile-site.zip"
cd "$PUBLISH_DIR"
rm -f skills-profile-site.zip
zip -r skills-profile-site.zip skills-profile-site -x "*.DS_Store" >/dev/null

echo "==> Done."
echo "Open: $STAGE/skills-docs-index.html"

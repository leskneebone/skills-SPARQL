#!/usr/bin/env bash
# Usage: scripts/run.sh <endpoint> <query-file> [format]
set -euo pipefail
EP="${1:?endpoint URL}"; QF="${2:?query file}"; FMT="${3:-text/csv}"
curl -sS -X POST \
  -H "Content-Type: application/sparql-query" \
  -H "Accept: $FMT" \
  --data-binary @"$QF" \
  "$EP"

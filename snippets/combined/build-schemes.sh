#!/usr/bin/env bash
set -euo pipefail

for ttl in snippets/combined/scheme-nst-*.ttl; do
  html="${ttl%.ttl}.html"
  pylode "$ttl" -o "$html"
  snippets/combined/inject-top-concepts.sh "$ttl" "$html"
done

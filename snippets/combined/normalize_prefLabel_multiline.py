#!/usr/bin/env python3
import sys
import re

if len(sys.argv) != 3:
    print("Usage: python3 normalize_prefLabel_multiline.py input.ttl output.ttl")
    sys.exit(2)

inp, outp = sys.argv[1], sys.argv[2]

with open(inp, "r", encoding="utf-8") as f:
    data = f.read()

# Regex:
# skos:prefLabel """ ... """@en
pattern = re.compile(
    r'skos:prefLabel\s+"""\s*(.*?)\s*"""@en',
    re.DOTALL
)

def repl(match):
    raw = match.group(1)
    # Collapse all whitespace (incl newlines) to single spaces
    collapsed = " ".join(raw.split())
    return f'skos:prefLabel "{collapsed}"@en'

new_data, n = pattern.subn(repl, data)

print(f"Rewrote {n} multiline skos:prefLabel values.")

with open(outp, "w", encoding="utf-8") as f:
    f.write(new_data)

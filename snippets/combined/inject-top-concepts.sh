#!/usr/bin/env bash
set -euo pipefail

ttl="$1"
html="$2"

tmpdir="$(mktemp -d)"
block="$tmpdir/block.html"
out="$tmpdir/out.html"

python3 - <<'PY' "$ttl" "$block"
import sys, html
from rdflib import Graph, URIRef, Literal
from rdflib.namespace import RDF

ttl_path = sys.argv[1]
block_path = sys.argv[2]

g = Graph()
g.parse(ttl_path, format="turtle")

SKOS = "http://www.w3.org/2004/02/skos/core#"
HAS_TOP = URIRef(SKOS + "hasTopConcept")
PREF = URIRef(SKOS + "prefLabel")
DEFN = URIRef(SKOS + "definition")
CS = URIRef(SKOS + "ConceptScheme")

# Find a scheme: prefer one typed ConceptScheme that hasTopConcept; else any subject with hasTopConcept
scheme = None
for s in g.subjects(RDF.type, CS):
    if any(True for _ in g.objects(s, HAS_TOP)):
        scheme = s
        break
if scheme is None:
    for s in g.subjects(HAS_TOP, None):
        scheme = s
        break
if scheme is None:
    # Nothing to inject
    open(block_path, "w", encoding="utf-8").write("")
    sys.exit(0)

tops = list(g.objects(scheme, HAS_TOP))

def best_lang_literal(objs, prefer=("en", "en-au", "en-AU")):
    lits = [o for o in objs if isinstance(o, Literal)]
    if not lits:
        return None
    # Prefer exact language matches, else any
    for lang in prefer:
        for l in lits:
            if (l.language or "").lower() == lang.lower():
                return l
    for l in lits:
        if l.language:
            return l
    return lits[0]

rows = []
for c in tops:
    lab = best_lang_literal(g.objects(c, PREF))
    dfn = best_lang_literal(g.objects(c, DEFN))
    lab_s = str(lab) if lab else g.namespace_manager.normalizeUri(c)
    dfn_s = str(dfn) if dfn else ""
    rows.append((lab_s, dfn_s))

# stable sort by label text
rows.sort(key=lambda t: t[0].lower())

def esc(s): return html.escape(s, quote=True)

parts = []
parts.append('<section id="top-concepts">')
parts.append('  <style>')
parts.append('    #top-concepts ul { list-style: none; padding-left: 10; }')
parts.append('    #top-concepts li { margin-bottom: 0.9rem; }')
parts.append('    #top-concepts .concept-def { margin-top: 0.25rem; }')
parts.append('  </style>')
parts.append('  <h2>Top concepts</h2>')
parts.append('  <ul>')
for lab_s, dfn_s in rows:
    if dfn_s:
        parts.append(f'    <li class="concept-item"><strong>{esc(lab_s)}</strong><div class="concept-def">{esc(dfn_s)}</div></li>')
    else:
        parts.append(f'    <li class="concept-item"><strong>{esc(lab_s)}</strong></li>')
parts.append('  </ul>')
parts.append('</section>')
open(block_path, "w", encoding="utf-8").write("\n".join(parts) + "\n")
PY

# Remove any existing top-concepts section
perl -0777 -pe 's|<section id="top-concepts">.*?</section>\s*||gs' "$html" > "$out"

# Inject after </h1> (fallback: after <body>)
BLOCK_PATH="$block" perl -0777 -i -pe '
  use strict;
  use warnings;
  local $/ = undef;

  my $block_path = $ENV{BLOCK_PATH};
  open my $bfh, "<:utf8", $block_path or die "Cannot read block\n";
  my $block = <$bfh>;
  close $bfh;

  if ($block =~ /^\s*$/s) { exit 0; }

  if (s|(</h1>)|$1\n$block|is) {
  } elsif (s|(<body[^>]*>)|$1\n$block|is) {
  } else {
    die "Could not find </h1> or <body> to inject after\n";
  }
' "$out"

cp "$out" "$html"
rm -rf "$tmpdir"

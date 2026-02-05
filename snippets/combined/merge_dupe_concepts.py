#!/usr/bin/env python3
from __future__ import annotations

import sys
from datetime import datetime
from rdflib import Graph, Namespace, URIRef, Literal
from rdflib.namespace import RDF, SKOS, DCTERMS, XSD


def parse_dt(lit: Literal) -> datetime | None:
    """Parse xsd:dateTime literals like 2026-02-05T06:28:25.227000+00:00"""
    try:
        s = str(lit)
        # Python can parse ISO8601 with timezone offset if it has ":" in offset (it does)
        return datetime.fromisoformat(s)
    except Exception:
        return None


def main() -> int:
    if len(sys.argv) != 3:
        print("Usage: python3 merge_dupe_concepts.py input.ttl output.ttl", file=sys.stderr)
        return 2

    in_path, out_path = sys.argv[1], sys.argv[2]

    g = Graph()
    g.parse(in_path, format="turtle")

    # Index concepts
    concepts = set(g.subjects(RDF.type, SKOS.Concept))

    # Build grouping key: (exact prefLabel literal, broader-set, inScheme-set)
    # prefLabel literal includes language tag, so exact match is automatic.
    groups: dict[tuple[Literal, tuple[str, ...], tuple[str, ...]], list[URIRef]] = {}

    for c in concepts:
        labels = list(g.objects(c, SKOS.prefLabel))
        if len(labels) != 1:
            # If there are 0 or >1 prefLabels, skip (you can tighten later)
            continue
        lab = labels[0]

        broaders = sorted({str(o) for o in g.objects(c, SKOS.broader) if isinstance(o, URIRef)})
        schemes = sorted({str(o) for o in g.objects(c, SKOS.inScheme) if isinstance(o, URIRef)})

        key = (lab, tuple(broaders), tuple(schemes))
        groups.setdefault(key, []).append(c)

    # Only groups with more than 1 are duplicates under your rule
    dup_groups = {k: v for k, v in groups.items() if len(v) > 1}

    if not dup_groups:
        print("No duplicate groups found under (prefLabel + broader-set + inScheme-set).")
        g.serialize(destination=out_path, format="turtle")
        return 0

    print(f"Found {len(dup_groups)} duplicate group(s).")

    # Helper: replace all occurrences of old as object with new
    def replace_object(old: URIRef, new: URIRef) -> None:
        to_change = list(g.triples((None, None, old)))
        for s, p, _ in to_change:
            g.remove((s, p, old))
            g.add((s, p, new))

    merged_count = 0
    removed_nodes = 0

    for (lab, broaders, schemes), nodes in dup_groups.items():
        # Deterministic keeper: smallest IRI string
        nodes_sorted = sorted(nodes, key=lambda u: str(u))
        keep = nodes_sorted[0]
        trash = nodes_sorted[1:]

        # If created timestamps differ, keep the earliest (optional cleanup)
        created_vals = []
        for n in nodes_sorted:
            for dt in g.objects(n, DCTERMS.created):
                if isinstance(dt, Literal) and (dt.datatype == XSD.dateTime or str(dt).startswith("20")):
                    parsed = parse_dt(dt)
                    if parsed:
                        created_vals.append((parsed, dt))
        earliest_created_lit = min(created_vals, key=lambda x: x[0])[1] if created_vals else None

        # Merge: move all triples from trash subjects to keep
        for t in trash:
            # Repoint incoming references first (so we don't lose links)
            replace_object(t, keep)

            # Copy outgoing triples
            outgoing = list(g.triples((t, None, None)))
            for _, p, o in outgoing:
                # We'll handle dcterms:created consolidation below
                if p == DCTERMS.created:
                    continue
                g.add((keep, p, o))

            # Remove trash subject triples (including created)
            g.remove((t, None, None))
            removed_nodes += 1

        # Consolidate dcterms:created on keeper to just earliest (optional; comment out if you prefer union)
        if earliest_created_lit is not None:
            for dt in list(g.objects(keep, DCTERMS.created)):
                g.remove((keep, DCTERMS.created, dt))
            g.add((keep, DCTERMS.created, earliest_created_lit))

        merged_count += 1

        print(f"- Merged {len(nodes_sorted)} concepts into keeper {keep}")
        print(f"  prefLabel: {lab}")
        print(f"  broader:  {', '.join(broaders) if broaders else '(none)'}")

    print(f"Done. Groups merged: {merged_count}. Concepts removed: {removed_nodes}.")
    g.serialize(destination=out_path, format="turtle")
    print(f"Wrote: {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

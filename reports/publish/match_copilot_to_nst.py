#!/usr/bin/env python3
from __future__ import annotations

import sys
import re
from pathlib import Path
from collections import defaultdict

from rdflib import Graph
from rdflib.namespace import SKOS
from rapidfuzz import process, fuzz

STOP = {
    # generic verbs / glue words that create false positives
    "conduct","perform","provide","monitor","assess","order","interpret","screen",
    "document","manage","use","ensure","review","support","apply","complete",
    "initial","ongoing","routine","basic","general",
    # very common
    "and","or","the","a","an","to","for","of","in","on","with","from","by","as",
    # common assessment-ish words (too ambiguous)
    "assessment","evaluate","evaluation","examination","tests","test","education",
    "signs","vital","visit","visits"
}

def norm_tokens(s: str) -> set[str]:
    toks = re.findall(r"[A-Za-z]+", s.lower())
    return {t for t in toks if len(t) >= 3 and t not in STOP}

def load_md_lines(path: Path) -> list[str]:
    items: list[str] = []
    for raw in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        line = raw.strip()
        if not line:
            continue
        if line.startswith("#"):
            continue
        if line.startswith("```"):
            continue
        # strip simple bullets if present
        line = re.sub(r"^[-*+]\s+", "", line)
        line = re.sub(r"^\d+\.\s+", "", line)
        # skip markdown tables
        if "|" in line and line.count("|") >= 2:
            continue
        items.append(line)

    # de-dupe preserving order
    seen = set()
    out = []
    for x in items:
        k = x.lower()
        if k in seen:
            continue
        seen.add(k)
        out.append(x)
    return out

def short_id(uri: str) -> str:
    uri = uri.rstrip("/")
    if "#" in uri:
        seg = uri.rsplit("#", 1)[1]
    else:
        seg = uri.rsplit("/", 1)[1]
    return seg.lower()

def load_nst_pref_labels(ttl_path: Path):
    g = Graph()
    g.parse(ttl_path.as_posix(), format="turtle")

    labels: list[str] = []
    label_to_ids = defaultdict(list)

    for s, _, o in g.triples((None, SKOS.prefLabel, None)):
        lbl = str(o).strip()
        if not lbl:
            continue
        labels.append(lbl)
        label_to_ids[lbl].append(short_id(str(s)))

    return labels, label_to_ids

def main(md_path: Path, ttl_path: Path, threshold: int):
    items = load_md_lines(md_path)
    labels, label_to_ids = load_nst_pref_labels(ttl_path)

    print("| copilotSkillsData.md | matched NST skill (id, prefLabel) |")
    print("|---|---|")

    for item in items:
        item_tokens = norm_tokens(item)

        # If it's too generic, don't match
        if len(item_tokens) < 2:
            print(f"| {item} |  |")
            continue

        # take top candidates then apply overlap gating
        candidates = process.extract(
            item,
            labels,
            scorer=fuzz.token_set_ratio,
            limit=8
        )

        chosen = None
        for cand_label, score, _ in candidates:
            if score < threshold:
                continue
            cand_tokens = norm_tokens(cand_label)
            # require meaningful overlap to prevent "conduct"+"assessment" nonsense
            if len(item_tokens & cand_tokens) < 2:
                continue
            chosen = cand_label
            break

        if not chosen:
            print(f"| {item} |  |")
            continue

        sid = label_to_ids[chosen][0]
        print(f"| {item} | {sid}, {chosen} |")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 match_copilot_to_nst.py <copilot.md> <nst.ttl> [threshold]", file=sys.stderr)
        sys.exit(2)

    md = Path(sys.argv[1]).expanduser()
    ttl = Path(sys.argv[2]).expanduser()
    thr = int(sys.argv[3]) if len(sys.argv) >= 4 else 92
    main(md, ttl, thr)

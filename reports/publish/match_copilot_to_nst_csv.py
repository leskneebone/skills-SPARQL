#!/usr/bin/env python3
from __future__ import annotations

import sys
import re
import csv
from pathlib import Path
from collections import defaultdict

from rdflib import Graph
from rdflib.namespace import SKOS
from rapidfuzz import process, fuzz


STOP = {
    "conduct","perform","provide","monitor","assess","order","interpret","screen",
    "document","manage","use","ensure","review","support","apply","complete",
    "initial","ongoing","routine","basic","general",
    "and","or","the","a","an","to","for","of","in","on","with","from","by","as",
    "assessment","evaluation","examination","tests","test","education",
    "signs","vital","visit","visits"
}


def norm_tokens(s: str) -> set[str]:
    toks = re.findall(r"[A-Za-z]+", s.lower())
    return {t for t in toks if len(t) >= 3 and t not in STOP}


def load_md_lines(path: Path) -> list[str]:
    items = []
    for raw in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        line = raw.strip()
        if not line:
            continue
        if line.startswith("#"):
            continue
        line = re.sub(r"^[-*+]\s+", "", line)
        line = re.sub(r"^\d+\.\s+", "", line)
        if "|" in line and line.count("|") >= 2:
            continue
        items.append(line)

    seen = set()
    out = []
    for x in items:
        k = x.lower()
        if k not in seen:
            seen.add(k)
            out.append(x)
    return out


def short_id(uri: str) -> str:
    uri = uri.rstrip("/")
    if "#" in uri:
        return uri.rsplit("#", 1)[1].lower()
    return uri.rsplit("/", 1)[1].lower()


def load_nst_labels(ttl_path: Path):
    g = Graph()
    g.parse(ttl_path.as_posix(), format="turtle")

    labels = []
    label_to_ids = defaultdict(list)

    for s, _, o in g.triples((None, SKOS.prefLabel, None)):
        label = str(o).strip()
        labels.append(label)
        label_to_ids[label].append(short_id(str(s)))

    return labels, label_to_ids


def main(md_path: Path, ttl_path: Path, out_csv: Path, threshold: int):
    items = load_md_lines(md_path)
    labels, label_to_ids = load_nst_labels(ttl_path)

    with out_csv.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["copilot_item", "nst_skill_id", "nst_prefLabel"])

        for item in items:
            item_tokens = norm_tokens(item)

            if len(item_tokens) < 2:
                writer.writerow([item, "", ""])
                continue

            candidates = process.extract(
                item,
                labels,
                scorer=fuzz.token_set_ratio,
                limit=8
            )

            chosen = None
            for label, score, _ in candidates:
                if score < threshold:
                    continue
                if len(item_tokens & norm_tokens(label)) < 2:
                    continue
                chosen = label
                break

            if not chosen:
                writer.writerow([item, "", ""])
                continue

            sid = label_to_ids[chosen][0]
            writer.writerow([item, sid, chosen])


if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python3 match_copilot_to_nst_csv.py <copilot.md> <nst.ttl> <output.csv> [threshold]")
        sys.exit(1)

    md = Path(sys.argv[1]).expanduser()
    ttl = Path(sys.argv[2]).expanduser()
    out = Path(sys.argv[3]).expanduser()
    thr = int(sys.argv[4]) if len(sys.argv) >= 5 else 92

    main(md, ttl, out, thr)

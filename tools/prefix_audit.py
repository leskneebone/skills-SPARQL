#!/usr/bin/env python3
import glob, re, csv
from collections import defaultdict

# Turtle prefix forms:
#   PREFIX abc: <http://example/>
#   @prefix abc: <http://example/> .
PREFIX_RE_1 = re.compile(r'^\s*PREFIX\s+([A-Za-z][\w\-]*)\s*:\s*<([^>]+)>\s*\.?\s*$', re.IGNORECASE)
PREFIX_RE_2 = re.compile(r'^\s*@prefix\s+([A-Za-z][\w\-]*)\s*:\s*<([^>]+)>\s*\.\s*$', re.IGNORECASE)

def canon_base(u: str) -> str:
    # canonicalise base IRI for comparison:
    # - strip surrounding spaces
    # - normalise repeated slashes (rare)
    # - keep trailing slash as meaningful (because you intentionally use / vs no /)
    return u.strip()

def main():
    files = sorted(glob.glob("*.ttl"))
    # prefix -> set(bases)
    p2b = defaultdict(set)
    # base -> set(prefixes)
    b2p = defaultdict(set)
    # occurrences for reporting
    occ = []  # (file, line_no, form, prefix, base)

    for fn in files:
        try:
            with open(fn, "r", encoding="utf-8", errors="replace") as f:
                for i, line in enumerate(f, start=1):
                    m1 = PREFIX_RE_1.match(line)
                    m2 = PREFIX_RE_2.match(line)
                    m = m1 or m2
                    if not m:
                        continue
                    prefix, base = m.group(1), canon_base(m.group(2))
                    form = "PREFIX" if m1 else "@prefix"
                    p2b[prefix].add(base)
                    b2p[base].add(prefix)
                    occ.append((fn, i, form, prefix, base))
        except Exception as e:
            print(f"ERROR reading {fn}: {e}")

    # Write full inventory for reference
    with open("prefix_inventory.csv", "w", newline="") as out:
        w = csv.writer(out)
        w.writerow(["file", "line", "form", "prefix", "base"])
        w.writerows(occ)

    # Type A: same prefix -> multiple bases
    clashes_a = [(p, sorted(list(bases))) for p, bases in p2b.items() if len(bases) > 1]
    with open("prefix_clashes_same_prefix.csv", "w", newline="") as out:
        w = csv.writer(out)
        w.writerow(["prefix", "base_count", "bases"])
        for p, bases in sorted(clashes_a, key=lambda x: (-len(x[1]), x[0].lower())):
            w.writerow([p, len(bases), " | ".join(bases)])

    # Type B: same base -> multiple prefixes
    clashes_b = [(b, sorted(list(prefixes))) for b, prefixes in b2p.items() if len(prefixes) > 1]
    with open("prefix_clashes_same_base.csv", "w", newline="") as out:
        w = csv.writer(out)
        w.writerow(["base", "prefix_count", "prefixes"])
        for b, prefixes in sorted(clashes_b, key=lambda x: (-len(x[1]), x[0].lower())):
            w.writerow([b, len(prefixes), " | ".join(prefixes)])

    print("Wrote:")
    print("  prefix_inventory.csv")
    print("  prefix_clashes_same_prefix.csv   (same prefix, different base IRI)")
    print("  prefix_clashes_same_base.csv     (same base IRI, different prefixes)")

if __name__ == "__main__":
    main()

from pathlib import Path
import re, json, urllib.parse, urllib.request
from collections import defaultdict

DATASET = "Skills"
GRAPH   = "https://data.jobsandskills.gov.au/graph/skills-sparql/combined"
ENDPOINT = f"http://localhost:3030/{DATASET}/sparql"

units_order = [
  "https://training.gov.au/training/details/BSBXCS302",
  "https://training.gov.au/training/details/ICTICT310",
  "https://training.gov.au/training/details/ICTICT317",
  "https://training.gov.au/training/details/ICTSAS305",
  "https://training.gov.au/training/details/ICTICT313",
  "https://training.gov.au/training/details/ICTNWK309",
  "https://training.gov.au/training/details/BSBXTW301",
  "https://training.gov.au/training/details/ICTNWK307",
  "https://training.gov.au/training/details/ICTPRG302",
  "https://training.gov.au/training/details/BSBCRT301",
  "https://training.gov.au/training/details/ICTWEB304",
  "https://training.gov.au/training/details/BSBXCS303",
]

text = Path("extracts/francis-mini.ttl").read_text(encoding="utf-8")
source_re = re.compile(r'^(<[^>]+>)\s+<http://purl\.org/dc/terms/source>\s+(<[^>]+>)\s*;', re.M)
unit_to_skills = defaultdict(list)
for m in source_re.finditer(text):
    unit_to_skills[m.group(2).strip("<>")].append(m.group(1).strip("<>"))

def sparql_json(query: str, timeout_s: int) -> dict:
    data = urllib.parse.urlencode({"query": query}).encode("utf-8")
    req = urllib.request.Request(ENDPOINT, data=data, headers={"Accept":"application/sparql-results+json"})
    with urllib.request.urlopen(req, timeout=timeout_s) as resp:
        return json.loads(resp.read().decode("utf-8"))

def get_skill_labels(skills):
    if not skills:
        return {}
    values = " ".join(f"<{s}>" for s in skills)
    q = f"""
PREFIX skos:<http://www.w3.org/2004/02/skos/core#>
PREFIX rdfs:<http://www.w3.org/2000/01/rdf-schema#>
SELECT ?s (SAMPLE(?lab) AS ?label)
WHERE {{
  GRAPH <{GRAPH}> {{
    VALUES ?s {{ {values} }}
    OPTIONAL {{ ?s skos:prefLabel ?pl FILTER(LANG(?pl)='en') }}
    OPTIONAL {{ ?s rdfs:label ?rl FILTER(LANG(?rl)='en') }}
    BIND(COALESCE(STR(?pl), STR(?rl), STR(?s)) AS ?lab)
  }}
}}
GROUP BY ?s
"""
    r = sparql_json(q, timeout_s=20)
    return { b["s"]["value"]: b["label"]["value"] for b in r["results"]["bindings"] }

def get_it2017_domains_for_unit(unit):
    q = f"""
PREFIX skos:<http://www.w3.org/2004/02/skos/core#>
PREFIX rdfs:<http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms:<http://purl.org/dc/terms/>
PREFIX schema:<https://schema.org/>

SELECT (GROUP_CONCAT(DISTINCT ?itLab; separator="; ") AS ?domains)
WHERE {{
  GRAPH <{GRAPH}> {{
    ?skill dcterms:source <{unit}> .
    OPTIONAL {{
      {{ ?skill ?link ?it2017 . }} UNION {{ <{unit}> ?link ?it2017 . }}
      FILTER(?link IN (
        schema:about, dcterms:subject,
        skos:related, skos:closeMatch, skos:exactMatch, skos:broadMatch, skos:narrowMatch
      ))
      FILTER(CONTAINS(LCASE(STR(?it2017)), "it2017"))

      OPTIONAL {{ ?it2017 skos:prefLabel ?pl FILTER(LANG(?pl)='en') }}
      OPTIONAL {{ ?it2017 rdfs:label ?rl FILTER(LANG(?rl)='en') }}
      OPTIONAL {{ ?it2017 dcterms:title ?tl }}
      BIND(COALESCE(STR(?pl), STR(?rl), STR(?tl), STR(?it2017)) AS ?itLab)
    }}
  }}
}}
"""
    r = sparql_json(q, timeout_s=60)
    b = r["results"]["bindings"]
    if not b:
        return []
    s = b[0].get("domains", {}).get("value", "").strip()
    return [x.strip() for x in s.split(";") if x.strip()] if s else []

def get_flags_for_skills(skills):
    if not skills:
        return (False, False)
    values = " ".join(f"<{s}>" for s in skills)
    q = f"""
SELECT
  (IF(EXISTS {{
     VALUES ?s {{ {values} }}
     ?s ?p ?o .
     FILTER(CONTAINS(LCASE(STR(?o)), "ict40120"))
   }}, 1, 0) AS ?certiv)
  (IF(EXISTS {{
     VALUES ?s {{ {values} }}
     ?s ?p2 ?o2 .
     FILTER(CONTAINS(LCASE(STR(?o2)), "sm0056"))
   }}, 1, 0) AS ?uc)
WHERE {{}}
"""
    r = sparql_json(q, timeout_s=20)
    row = r["results"]["bindings"][0]
    return (row["certiv"]["value"] == "1", row["uc"]["value"] == "1")

out_lines = []
out_lines.append("Cert III unit\tNST skills evidenced\tIT2017 domains\tICT40120 aligned?\tSM0056 aligned?")

for unit in units_order:
    code = unit.rsplit("/", 1)[-1]
    skills = sorted(set(unit_to_skills.get(unit, [])), key=str.casefold)

    labels = get_skill_labels(skills)
    skills_txt = "; ".join(labels.get(s, s) for s in skills)

    try:
        it_txt = "; ".join(sorted(set(get_it2017_domains_for_unit(unit)), key=str.casefold))
    except TimeoutError:
        it_txt = "(timeout)"

    certiv, uc = get_flags_for_skills(skills)
    out_lines.append(f"{code}\t{skills_txt}\t{it_txt}\t{'Yes' if certiv else ''}\t{'Yes' if uc else ''}")

tsv = "\n".join(out_lines) + "\n"
Path("reports/francis_word_table.tsv").write_text(tsv, encoding="utf-8")
print(tsv)
print("Wrote reports/francis_word_table.tsv")

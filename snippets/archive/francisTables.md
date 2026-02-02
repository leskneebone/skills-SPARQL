
## the table!

Cert III unit	NST skills evidenced	IT2017 domains	ICT40120 aligned?	SM0056 aligned?
BSBXCS302	Cyber Threat Identification; Breach Blocking; Policy Review			
ICTICT310				
ICTICT317	Operating Environment Advantage Evaluation; Soe Application Reporting Oversight; Soe Deployment Decision-Making; Soe Deployment Assessment; End User Device Analysis			
ICTSAS305	Ict Documentation Development; Ict Technical Instruction			
ICTICT313	Ip Policy Interpretation; Ict Policy Access Management			
ICTNWK309	Network Operating System Feature Assessment; Network Os Upgrade Strategy			
BSBXTW301	Commitment Communication			
ICTNWK307	Network Systems Problem Solving			
ICTPRG302	Algorithm Design; Programming Problem Solving	Software Fundamentals		
BSBCRT301	Assumption Evaluation; Connection Assessment; Critical Questioning			
ICTWEB304	Web Page Accessibility Assessment; Web Directory Structure Management; Web Ftp Transfer Management; Webpage Hyperlink Integration; Web Page Multimedia Integration; Web Text Design			
BSBXCS303	Personal Information Data Management; Sensitive Pii Identification; Cyber Security Stakeholder Consultation; Infrastructure Fault Reporting; Privacy Policy Application; Sensitive Data Identification	

<---------------->

Perfect — for **MS Word**, the main things are:

* keep the table simple (no Markdown pipes)
* put the **caption as a normal Word caption** (or bold line above the table)
* include the short narrative **immediately after the table**, not embedded in it

Below is **exactly what to paste into Word**, in order.

---

## 1) Table (Word-friendly)

Paste this **as plain text** into Word, then use
**Insert → Table → Convert Text to Table…**
with **Separate text at: Tabs**.

```
IT2017 concept	Francis-mapped NST skills	Skills	Source units
Software Fundamentals (https://data.jobsandskills.gov.au/def/it2017/ITE-SWF)	2	Programming Problem Solving; Algorithm Design	ICTPRG302
```

After conversion:

* you can turn the IT2017 concept into a clickable hyperlink
* you can centre or right-align the “2” column if you like
* semicolons are better than pipes for Word tables

---

## 2) Caption (paste immediately above the table)

**Table X. Worked example: VET unit → NST skills → IT2017 concept (current graph coverage).**

(If you’re using Word’s caption feature:
*References → Insert Caption → Label: Table*.)

---

## 3) Short narrative (paste immediately after the table)

This table demonstrates the method for computing overlap between vocational achievement and higher-education curriculum structure using skills as a stable semantic bridge. In the graph, NST skills are linked to completed TGA units via `dcterms:source`. Where either units or skills are linked to IT2017 curriculum concepts (e.g. via `schema:about`, `dcterms:subject`, or SKOS mapping predicates), an “overlap view” can be generated that identifies which curriculum concepts are evidenced by a learner’s completed units.

In the current dataset, the unit **ICTPRG302 (Apply introductory programming techniques)** contributes two NST skills — **Programming Problem Solving** and **Algorithm Design** — which align to IT2017 **Software Fundamentals**. This provides an auditable proof-of-method: vocational unit completion is connected to higher-education curriculum concepts through explicit skill entities with clear provenance back to training.gov.au units. Expanding the overlap beyond this worked example requires additional unit- or skill-to-IT2017 mappings in the graph, rather than changes to the method itself.

---

## 4) Optional tightening (if the audience is very executive)

If you want a **one-sentence version** instead of the full narrative, use this instead:

> This worked example shows how completion of ICTPRG302 maps to two NST skills (Programming Problem Solving; Algorithm Design), which align to IT2017 Software Fundamentals, demonstrating a unit → skill → curriculum concept pathway with explicit provenance.

---

If you want, next we can:

* rewrite this to match **APS / JSA house style**, or
* compress it to fit a **single half-page briefing**, or
* add a **one-line method call-out** you can reuse elsewhere in the document.


<----------------->






DATASET="Skills"
GRAPH="https://data.jobsandskills.gov.au/graph/skills-sparql/combined"
OUT="reports/francis_it2017_overlap.csv"

mkdir -p reports

curl -sS -H "Accept: text/csv" "http://localhost:3030/${DATASET}/sparql" \
  --data-urlencode "query=
PREFIX skos:   <http://www.w3.org/2004/02/skos/core#>
PREFIX dcterms:<http://purl.org/dc/terms/>
PREFIX schema: <https://schema.org/>
PREFIX rdfs:   <http://www.w3.org/2000/01/rdf-schema#>
PREFIX tgaunit:<https://training.gov.au/training/details/>

SELECT
  ?it2017
  (SAMPLE(?itLabel) AS ?it2017Label)
  (COUNT(DISTINCT ?skill) AS ?francisSkillsMapped)
  (GROUP_CONCAT(DISTINCT ?skillLabel; separator=\" | \") AS ?skills)
  (GROUP_CONCAT(DISTINCT ?unitCode; separator=\", \") AS ?sourceUnits)
WHERE {
  GRAPH <${GRAPH}> {

    VALUES ?unit {
      tgaunit:BSBXCS302
      tgaunit:ICTICT310
      tgaunit:ICTICT317
      tgaunit:ICTSAS305
      tgaunit:ICTICT313
      tgaunit:ICTNWK309
      tgaunit:BSBXTW301
      tgaunit:ICTNWK307
      tgaunit:ICTPRG302
      tgaunit:BSBCRT301
      tgaunit:ICTWEB304
      tgaunit:BSBXCS303
    }

    BIND(STRAFTER(STR(?unit), \"https://training.gov.au/training/details/\") AS ?unitCode)

    ?skill dcterms:source ?unit .
    OPTIONAL { ?skill skos:prefLabel ?skillLabel }

    {
      ?skill ?link ?it2017 .
    }
    UNION
    {
      ?unit ?link ?it2017 .
    }

    FILTER(?link IN (
      schema:about,
      dcterms:subject,
      skos:related,
      skos:closeMatch,
      skos:exactMatch,
      skos:broadMatch,
      skos:narrowMatch
    ))

    FILTER(
      CONTAINS(LCASE(STR(?it2017)), \"it2017\")
      || EXISTS {
        ?it2017 skos:inScheme ?scheme .
        FILTER(CONTAINS(LCASE(STR(?scheme)), \"it2017\"))
      }
    )

    OPTIONAL { ?it2017 skos:prefLabel ?itPL }
    OPTIONAL { ?it2017 rdfs:label ?itRL }
    OPTIONAL { ?it2017 dcterms:title ?itTL }
    BIND(COALESCE(STR(?itPL), STR(?itRL), STR(?itTL), STR(?it2017)) AS ?itLabel)
  }
}
GROUP BY ?it2017
ORDER BY DESC(?francisSkillsMapped) LCASE(STR(?it2017))
" > "${OUT}"

echo "Wrote: ${OUT}"
```

Now you’ve got a durable artefact for the report: `reports/francis_it2017_overlap.csv`.

---

### 2) Convert CSV → Markdown table (drop straight into the report)

If your report is markdown (or you want a markdown table you can paste into Word, etc.), do:

```bash
cd /Users/leskneebone/Projects/skills-SPARQL

python3 - <<'PY'
import csv, sys

path = "reports/francis_it2017_overlap.csv"
with open(path, newline="", encoding="utf-8") as f:
    rows = list(csv.reader(f))

if not rows:
    print("No rows in CSV")
    sys.exit(0)

header = rows[0]
data = rows[1:]

# Keep the table readable: these cols are usually huge
# You can tweak this after you see output.
max_width = {
    "skills": 80,
    "sourceUnits": 80,
}

def trunc(colname, s):
    s = s or ""
    w = max_width.get(colname, None)
    if w and len(s) > w:
        return s[: w-3] + "..."
    return s

# compute column names
colnames = header

# markdown header
print("| " + " | ".join(colnames) + " |")
print("|" + "|".join(["---"] * len(colnames)) + "|")

# rows
for r in data[:50]:  # cap at 50 rows for report readability
    out = []
    for colname, cell in zip(colnames, r):
        out.append(trunc(colname, cell).replace("\n", " "))
    print("| " + " | ".join(out) + " |")

if len(data) > 50:
    print(f"\n*(Showing first 50 of {len(data)} rows; full table in `{path}`.)*")
PY
```

That will print a **paste-ready markdown table**.

---

## Draft text for the report (template)

Once you run the query and we see what it actually returns, I’ll tighten the wording. For now, here’s a solid “insert block” you can paste and we’ll replace bracketed bits:

> **Francis → IT2017 overlap (skills as the semantic bridge)**
> Francis completed a set of TGA units within a Certificate III in Information Technology. Using the NST dataset, we can enumerate the NST skills that are explicitly evidenced by those completed units (via `dcterms:source` links to training.gov.au unit IRIs). We then align those skills (and/or the units themselves) to IT2017 knowledge areas using existing graph links (e.g., `schema:about`, `dcterms:subject`, and SKOS mapping predicates).
>
> The resulting overlap table (Table X) shows, for each IT2017 concept, (i) the number of Francis-derived NST skills that map to it, (ii) the specific skills, and (iii) the originating TGA units. This demonstrates how NST skills and their provenance metadata can function as a durable cross-sector “semantic layer” to support credit-transfer reasoning between vocational units and higher-education curriculum structures.

When you’ve run the CSV export, paste the first ~10 rows (or the markdown table output) and I’ll:

* choose the *best* columns for a report table,
* generate a clean caption + interpretation,
* and write the “so what?” paragraph that leads into the Cert IV vs Bachelor decision.

---

## Terminal vs Fuseki UI — which should we use?

**My recommendation: terminal from now on**, because you can:

* save results to `reports/…`,
* commit queries + outputs,
* rerun everything later (which is gold for the report).

But if you’d rather click-run in Fuseki UI for a bit, no worries — I can format the query for that too. The only real difference is: in terminal you can reliably **save outputs** without copy/paste pain.

If you run the CSV export now, tell me:

* did it produce rows, and
* roughly how many rows?

(If it’s empty, I’ll give you one short diagnostic query to find which linking predicate/path is missing.)

Table X. Francis → IT2017 overlap (via NST skills evidenced by TGA unit completion).
This table summarises IT2017 curriculum concepts that are supported by NST skills associated with the TGA units Francis completed in Certificate III in IT. In the current graph, unit ICTPRG302 (Apply introductory programming techniques) is linked (via dcterms:source) to two NST skills — Programming Problem Solving and Algorithm Design — which in turn align to IT2017 Software Fundamentals. This provides an auditable “skills as semantic bridge” example: vocational achievement is connected to higher-education curriculum structure through stable skill entities with clear provenance back to specific units.

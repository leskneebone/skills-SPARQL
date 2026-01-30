
1. **Make the text boring** (plain ASCII where possible), and
2. **Make literals Turtle-safe** (no unescaped `"` inside a `"`…`"` literal).

Here’s a practical “spreadsheet-first” cleaning plan that works even when you’re in a locked-down environment.

---

## What to clean in the spreadsheet (highest value)

### 1) Internal double-quotes inside any field that becomes a Turtle string

Your example:

`needs assessment; referral pathways; "specialist resources"; case management`

That will **break Turtle** unless you either:

* remove the internal quotes, or
* escape them as `\"` before conversion.

For `schema:keywords`, removing them is usually fine (keywords aren’t prose).

✅ **Rule:** *No raw `"` characters allowed in any cell that becomes a `"..."` literal.*

---

### 2) “Smart punctuation” + invisible Unicode

These are the usual validators/converters killers:

* Curly quotes: `“ ” ‘ ’`
* Long dashes: `– —` (you saw “hyphens” outside Latin-1)
* Non-breaking space: `U+00A0` (looks like a normal space)
* “Zero width” junk: `U+200B` etc (you already checked some ranges; still worth re-checking per-column)
* Subscript digits: `₂` (CO₂) — these aren’t *wrong*, but they often trigger “ambiguous unicode” warnings and can cause downstream library edge-cases

✅ **Rule:** replace with plain equivalents:

* `“` `”` → `"`
* `‘` `’` → `'`
* `–` `—` → `-`
* NBSP → normal space
* `₂` → `2` (or `CO2`)

---

### 3) Line breaks and tabs inside cells

Even if Turtle supports multi-line literals, a lot of spreadsheet-to-RDF tools choke or generate ugly output.

✅ **Rule:** replace `CR/LF` and tabs with a space.

---

## How to do this in Excel (no add-ins required)

### A) Targeted Find/Replace (fastest)

In Excel:

1. Select the columns that will become literals (keywords, labels, definitions, learning outcomes).
2. `Ctrl+H` (Find/Replace) and do these pairs:

* Find: `“` Replace: `"`
* Find: `”` Replace: `"`
* Find: `‘` Replace: `'`
* Find: `’` Replace: `'`
* Find: `—` Replace: `-`
* Find: `–` Replace: `-`

Line breaks:

* Find: press `Ctrl+J` (in the Find box) Replace: a single space
  (Excel doesn’t show the character; that’s normal.)

Tabs:

* Find: `Ctrl+Tab` won’t work; instead use a helper formula (below) if tabs exist.

NBSP:

* This is the annoying one because you can’t “type it”.
* Use the helper formula method below (it catches it reliably).

---

### B) Helper “clean” column (most reliable, catches NBSP + weird chars)

Create a new column next to the field you care about (say keywords in `A2`), then use something like:

```excel
=TRIM(
  SUBSTITUTE(
    SUBSTITUTE(
      SUBSTITUTE(
        SUBSTITUTE(
          SUBSTITUTE(
            SUBSTITUTE(A2,CHAR(160)," "),
          CHAR(10)," "),
        CHAR(13)," "),
      "“",""""),
    "”",""""),
  """","")
)
```

What it does:

* converts NBSP to space
* converts line breaks to spaces
* converts curly quotes to straight quotes
* then **removes all `"` entirely** (last SUBSTITUTE)

If you’d rather **escape quotes** instead of removing them (sometimes you might), change the last line to:

```excel
SUBSTITUTE(A2, """", "\""")
```

…but note: getting the escaping exactly right in Excel is fiddly; removal is safer for keywords.

Then:

* Fill down
* Copy the helper column → Paste Special → Values back over the original column

---

## “C++” / “C#” style encoding-friendly conventions

Turtle is fine with `C++` and `C#` as plain text. The problem only arises if you ended up with something like:

`"C#""@en`  (that extra quote is fatal)

So the convention is simply:

* keep as `C++` and `C#` (plain ASCII), and
* ensure your converter/cleanup never introduces a stray quote before `@en`.

If you ever *do* need literal quotes *inside* a string, the Turtle-correct way is escaping: `\"` — but for skills/keywords it’s usually not worth it.

---

## What I’d do next given your situation

1. Pick **one** high-risk column (almost always `schema:keywords`) and run the helper-column cleanup that:

* removes raw quotes
* normalises NBSP + line breaks
* replaces curly punctuation

2. Export again / re-run the converter.

3. Only then move on to the next “problem column” (definitions, learning outcomes, etc.).

This keeps you out of the doom spiral where you touch everything and can’t tell what fixed what.

---

If you tell me what *format* you’re starting from for the new extraction (Excel `.xlsx`? CSV? something else) and whether the KurrawongAI converter expects “already-clean strings” vs “it will escape things”, I can tailor the exact Excel cleaning formulas so they match your pipeline.

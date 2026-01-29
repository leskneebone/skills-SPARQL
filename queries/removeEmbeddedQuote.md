Thanks — those three lines look *totally normal* Turtle, and importantly: **none of them contain internal quotes inside `schema:keywords`**. So if you’re seeing examples like:

```turtle
schema:keywords "...; "specialist resources"; ..."@en ;
```

then either:

1. those lines are elsewhere in the file, **or**
2. the “quotes” aren’t ASCII `"` (they’re smart quotes like `“ ”`), **or**
3. the file contains odd hidden characters (NBSP etc.) that are making VS Code matching flaky.

Given you suspect “bad characters”, here’s the most reliable VS Code approach: **protect the outer quotes, strip the rest, restore**. This avoids needing fancy lookarounds and it works even when there are multiple internal quotes.

---

## Bulletproof 3-step fix in VS Code (Replace All)

### Step 1 — protect the opening quote of schema:keywords

**Find (regex ON):**

```regex
(schema:keywords\s+)"
```

**Replace:**

```regex
$1§§OPEN§§
```

### Step 2 — protect the closing quote (before @lang or before ;/.)

This catches `"@en` as well as lines with no language tag.

**Find (regex ON):**

```regex
"(?=(?:@[a-zA-Z-]+)?\s*[;.])
```

**Replace:**

```text
§§CLOSE§§
```

### Step 3 — delete *all remaining* quote characters

**Find (regex OFF):**

```
"
```

**Replace:**

```
```

(empty)

### Step 4 — restore the protected delimiters

**Find (regex OFF):**

```
§§OPEN§§
```

Replace with:

```
"
```

**Find (regex OFF):**

```
§§CLOSE§§
```

Replace with:

```
"
```

✅ Result: only the *delimiting* quotes remain; all internal quotes inside keywords are removed.

Find:
[\u200B-\u200F\u202A-\u202E\u2066-\u2069\uFEFF]

Find:
[₀₁₂₃₄₅₆₇₈₉]


Do you get any results? If yes, delete them first — that’s the #1 candidate for the validator freeze.

---

## If the “quotes” are actually smart quotes

Run these first (regex ON):

**Find:**

```regex
[“”]
```

Replace with:

```text
"
```

(Then do the 4-step process above.)

**Find:**
```regex
[‘’]
```

Replace with:

'

\u00A0

Find:
[–—]

Replace:

-

Find:

…

Replace:

...


Find:

[\u200B-\u200F\u202A-\u202E\u2066-\u2069\uFEFF]

Replace:



---

## Quick reality check on your snippet

These are fine:

```turtle
schema:keywords "aquatic animal disease; ..."@en .
```

So the cleanup will only change lines that actually contain extra quotes.

---

If you paste **one real problematic keywords line** (with the weird quotes), I can tell you immediately whether it’s smart quotes vs ASCII quotes vs escaped `\"` — but the “protect + strip + restore” method above will work regardless.

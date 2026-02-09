```mermaid
flowchart LR
  %% Diagram 1 — direct mappings (VET↔VET easier than VET↔HE)

  subgraph CertIII["TGA Cert III (Qualification)"]
    direction TB
    C3a["Unit A"]:::unit
    C3b["Unit B"]:::unit
    C3d["Elective X"]:::unit
  end

  subgraph CertIV["TGA Cert IV (Qualification)"]
    direction TB
    C4a["Unit A'"]:::unit
    C4b["Unit B'"]:::unit
    C4x["Elective X (shared)"]:::unit
  end

  subgraph UCBIT["Uni Canberra Bachelor IT (Major/Specialisation)"]
    direction TB
    UC1["Course 101"]:::unit
    UC2["Course 102"]:::unit
    UC3["Course 201"]:::unit
    UC4["Course 202"]:::unit
  end

  CertIII -- "Less complicated (shared units / similar outcomes)" --> CertIV
  CertIII -. "Less direct (different learning-outcome semantics; uni-specific, no national framework)" .-> UCBIT
  CertIV  -. "Less direct (same as Cert III)" .-> UCBIT

  classDef unit fill:#fff,stroke:#333,stroke-width:1px;
```

```mermaid
flowchart LR
  %% Diagram 2 — attempt mapping via IT2017 (helps HE more than VET)
  subgraph CertIII["TGA Cert III"]
    C3["Units (A…n)"]:::unit
  end

  subgraph CertIV["TGA Cert IV"]
    C4["Units (A…n)"]:::unit
  end

  subgraph UCBIT["UC B.IT (Maj/Specialisation)"]
    UC["Courses (101…n)"]:::unit
  end

  subgraph IT2017["ACM IT2017"]
    KA["Domains / Subdomains"]:::scheme
  end

  %% HE aligns (assumed mapping)
  UCBIT -- "Mapped (assumed) UC courses → IT2017" --> IT2017

  %% VET: possible mapping, with no explicit IT2017 mapping
  CertIII -. "Constructed by not authoritative TGA > IT2017 mapping" .-> IT2017
  CertIV  -. "Constructed by not authoritative TGA > IT2017 mapping" .-> IT2017

  %% therefore crosswalk is still partial/uneven
  CertIII -. "Partial harmonisation via IT2017" .-> UCBIT
  CertIV  -. "Partial harmonisation via IT2017" .-> UCBIT

  classDef unit fill:#fff,stroke:#333,stroke-width:1px;
  classDef scheme fill:#f8f8f8,stroke:#333,stroke-width:1px;
```

```mermaid
flowchart LR
  %% Diagram 3 — NST Skills as the bridge (indexes VET + HE + IT2017)
  subgraph CertIII["TGA Cert III"]
    C3["Units (A…n)"]:::unit
  end

  subgraph CertIV["TGA Cert IV"]
    C4["Units (A…n)"]:::unit
  end

  subgraph UCBIT["UC Bachelor IT (Maj/Specialisation)"]
    UC["Courses (101…n)"]:::unit
  end

  subgraph IT2017["IT2017"]
    KA["Domains / Subdomains"]:::scheme
  end

  subgraph NST["National Skills Taxonomy (NST Skills)"]
    Skills["Skill concepts (SK…)\n(+ domains / groupings)"]:::hero
  end

  %% NST indexes everything
  CertIII -->|"Extract/index learning outcomes → skills"| NST
  CertIV  -->|"Extract/index learning outcomes → skills"| NST
  UCBIT  -->|"Extract/index learning outcomes → skills"| NST
  IT2017 -->|"Align domains → skills"| NST

  %% Credit transfer becomes skill-mediated
  CertIII == "Skill-mediated equivalence + gap analysis" ==> UCBIT
  CertIV  == "Skill-mediated equivalence + gap analysis" ==> UCBIT
  CertIII == "Skill-mediated equivalence (shared skills)" ==> CertIV

  classDef unit fill:#fff,stroke:#333,stroke-width:1px;
  classDef scheme fill:#f8f8f8,stroke:#333,stroke-width:1px;
  classDef hero fill:#fff,stroke:#333,stroke-width:2px;
```

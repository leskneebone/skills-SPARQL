```mermaid
flowchart LR

  %% =========================
  %% NST PROFILE ARTEFACTS (published by JSA/DEWR)
  %% =========================
  subgraph NST["NST Profile artefacts (JSA/DEWR)"]
    direction LR

    Ont["NST Ontology\n<https://test.linked.data.gov.au/def/nst/ontology>"]

    NSTScheme["NST scheme\n<https://test.linked.data.gov.au/def/nst>"]
    Cog["Cognitive Domain\n<https://test.linked.data.gov.au/def/nst-cognitive-domain>"]
    Dig["Digital Intensity\n<https://test.linked.data.gov.au/def/nst-digital-intensity>"]
    Fut["Future Readiness\n<https://test.linked.data.gov.au/def/nst-futureready>"]
    Learn["Learning Context\n<https://test.linked.data.gov.au/def/nst-learning-context>"]
    Level["Skill Levels\n<https://test.linked.data.gov.au/def/nst-level>"]
    Nature["Skill Nature\n<https://test.linked.data.gov.au/def/nst-nature>"]
    Trans["Transferability\n<https://test.linked.data.gov.au/def/nst-transferability>"]
    Work["Work Context\n<https://test.linked.data.gov.au/def/nst-work-context>"]
    Percent["Percent Range\n<https://test.linked.data.gov.au/def/nst-percent-range>"]

    Skill["NST Skill\n(skos:Concept)"]
    Narrower["NST Skill (narrower)"]

    Skill -->|skos:narrower| Narrower
    Skill -->|skos:inScheme| NSTScheme

    %% Facet links (predicate labels illustrative)
    Skill -->|nst:cognitiveDomain| Cog
    Skill -->|nst:digitalIntensity| Dig
    Skill -->|nst:futureReadiness| Fut
    Skill -->|nst:learningContext| Learn
    Skill -->|nst:skillLevel| Level
    Skill -->|nst:skillNature| Nature
    Skill -->|nst:transferability| Trans
    Skill -->|nst:workContext| Work
    Skill -->|nst:percentRange| Percent

    Ont -->|defines terms| NSTScheme
  end

  %% =========================
  %% EXTERNAL REFERENCE FRAMEWORKS (not published by NST Profile)
  %% =========================
  subgraph EXT["External reference frameworks (not NST Profile)"]
    direction LR

    Unit["Training.gov.au Unit"]
    Qual["Training.gov.au Qualification"]
    Pack["Training Package"]

    ASCED["ASCED"]
    AQFType["AQF credential type"]
    AQFLevel["AQF level"]

    ANZSCO["ANZSCO occupation (ABS)"]
    OSCA["OSCA occupation"]
  end

  %% =========================
  %% JSA ARTEFACTS ABOUT EXTERNALS
  %% =========================
  subgraph JSAEXT["JSA artefacts about external frameworks"]
    direction LR
    OccProfile["JSA Occupation Profile\n(schema:CreativeWork)"]
  end

  %% =========================
  %% CROSS-BOUNDARY LINKS
  %% =========================

  Skill -->|dcterms:source (evidence)| Unit

  Qual -->|dcterms:isPartOf| Pack
  Qual -->|schema:about| ASCED
  Qual -->|schema:credentialCategory| AQFType
  AQFType -->|schema:about| AQFLevel

  %% Corrected canonical direction:
  Qual -->|schema:about| ANZSCO

  OccProfile -->|schema:about| ANZSCO

  ANZSCO -->|skos:exactMatch| OSCA
```

flowchart LR

  %% =========================
  %% NST PROFILE ARTEFACTS (published by JSA/DEWR)
  %% =========================
  subgraph NST["NST Profile artefacts (published by JSA/DEWR)"]
    direction LR

    Skill["NST Skill (skos:Concept)"]
    NarrowerSkill["NST Skill (narrower)"]

    NSTScheme["NST scheme\n<.../def/nst>"]
    Ontology["NST Ontology\n<.../def/nst/ontology>"]

    Cog["NST Cognitive Domain scheme\n<.../def/nst-cognitive-domain>"]
    Dig["NST Digital Intensity scheme\n<.../def/nst-digital-intensity>"]
    Fut["NST Future Readiness scheme\n<.../def/nst-futureready>"]
    Learn["NST Learning Context scheme\n<.../def/nst-learning-context>"]
    Level["NST Skill Levels scheme\n<.../def/nst-level>"]
    Nature["NST Skill Nature scheme\n<.../def/nst-nature>"]
    Trans["NST Skill Transferability scheme\n<.../def/nst-transferability>"]
    Work["NST Work Context scheme\n<.../def/nst-work-context>"]
    Percent["NST Percent Range scheme\n<.../def/nst-percent-range>"]

    Skill -->|skos:narrower| NarrowerSkill
    Skill -->|skos:inScheme| NSTScheme

    %% Attribute / facet links (predicate names are placeholders)
    Skill -->|nst:cognitiveDomain| Cog
    Skill -->|nst:digitalIntensity| Dig
    Skill -->|nst:futureReadiness| Fut
    Skill -->|nst:learningContext| Learn
    Skill -->|nst:skillLevel| Level
    Skill -->|nst:skillNature| Nature
    Skill -->|nst:transferability| Trans
    Skill -->|nst:workContext| Work
    Skill -->|nst:percentRange| Percent

    %% Ontology defines the terms used above
    Ontology -->|rdfs:seeAlso| NSTScheme
  end

  %% =========================
  %% EXTERNAL REFERENCE FRAMEWORKS (not published by NST Profile)
  %% =========================
  subgraph EXT["External reference frameworks (not published by NST Profile)"]
    direction LR

    Unit["Training.gov.au Unit\n(tga unit URI)"]
    Qual["Training.gov.au Qualification\n(tga qualification URI)"]
    Package["Training Package"]

    ASCED["ASCED"]
    AQFType["AQF credential type"]
    AQFLevel["AQF level"]

    ANZSCO["ANZSCO occupation (ABS)"]
    OSCA["OSCA occupation"]
  end

  %% =========================
  %% JSA ARTEFACTS ABOUT EXTERNALS (published by JSA/DEWR, but about externals)
  %% =========================
  subgraph JSAEXT["JSA artefacts about external frameworks"]
    direction LR
    OccProfile["JSA Occupation Profile\n(schema:CreativeWork)"]
  end

  %% =========================
  %% CROSS-BOUNDARY LINKS (keep ownership clear)
  %% =========================

  %% Evidence link: skills are evidenced by training units
  Skill -->|dcterms:source (evidence)| Unit

  %% Qualification classification (external)
  Qual -->|schema:about| ASCED
  Qual -->|schema:credentialCategory| AQFType
  AQFType -->|schema:about| AQFLevel

  %% Occupation crosswalk (external)
  ANZSCO -->|skos:exactMatch| OSCA

  %% JSA occupation profile is about ANZSCO (already in your occProfiles TTL)
  OccProfile -->|schema:about| ANZSCO

  %% Canonical direction you just implemented:
  %% Qualification is about ANZSCO (in your updated tgaunitqual TTL)
  Qual -->|schema:about| ANZSCO

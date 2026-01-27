
```mermaid
flowchart TB

flowchart TB
  %% Core SKOS
  CS[skos: Concept<br/>Scheme]
  C[skos:<br/>Concept]

  C -->|skos:inScheme| CS

  %% PROV attribution pattern
  AG{{prov:<br/>Agent}}
  ATT[prov:<br/>Attribution]

  ATT -->|prov:agent| AG
  ATT -->|dcat:hasRole| C

  %% DCAT resource pattern
  R[dcat:<br/>Resource]
  CAT[dcat:<br/>Catalog]
  DS[dcat:<br/>Dataset]

  R -->|prov:qualifiedAttribution| ATT
  CAT --> R
  DS --> R

  %% Catalog instances
  IAC[IDN Indigenous<br/>Agents Catalogue]
  IDC[IDN Dataset<br/>Catalogue]

  IAC -->|rdf:type| CAT
  IDC -->|rdf:type| CAT

  IAC -->|dcterms:hasPart| AG
  IDC -->|dcterms:hasPart| DS

  %% External concept schemes / vocabularies
  LCL[LC Labels]
  CARE[CARE<br/>Principles]
  FAIR[FAIR<br/>Principles]
  ROLE[IDN Role<br/>Codes]
  THEME[IDN Data<br/>Themes]

  LCL -->|rdf:type| CS
  CARE -->|rdf:type| CS
  FAIR -->|rdf:type| CS
  ROLE -->|rdf:type| CS
  THEME -->|rdf:type| CS

  C -->|skos:inScheme| ROLE
  R -->|dcat:theme [1..*]| THEME

```

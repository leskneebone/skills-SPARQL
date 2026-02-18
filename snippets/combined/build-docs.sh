#!/usr/bin/env bash
set -euo pipefail

FUSEKI="http://localhost:3030"
DATASET="Skills"
GRAPH_PROFILE="https://data.jobsandskills.gov.au/graph/skills-sparql/profile-input"
GRAPH_LITTLE="https://data.jobsandskills.gov.au/graph/skills-sparql/nst-little-schemes"

# 1) Profile page (profile header only)
curl -sS -H "Accept: text/turtle" "$FUSEKI/$DATASET/sparql" \
  --data-urlencode 'query=
PREFIX prof: <http://www.w3.org/ns/dx/prof/>
PREFIX owl:  <http://www.w3.org/2002/07/owl#>

CONSTRUCT { ?s ?p ?o . }
WHERE {
  GRAPH <https://data.jobsandskills.gov.au/graph/skills-sparql/profile-input> {
    VALUES ?s { <https://test.linked.data.gov.au/def/skills-profile> }
    ?s ?p ?o .
  }
}' \
  -o profile-only.ttl

pylode -p vocpub profile-only.ttl -o skills-profile.html

# 2) Ontology page (SkillLevel + digitalIntensity, pulled from profile-input + little-schemes)
curl -sS -H "Accept: text/turtle" "$FUSEKI/$DATASET/sparql" \
  --data-urlencode 'query=
PREFIX owl:  <http://www.w3.org/2002/07/owl#>
PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX dcterms: <http://purl.org/dc/terms/>

CONSTRUCT {
  <https://test.linked.data.gov.au/def/nst/ontology> a owl:Ontology ;
    rdfs:label "NST Ontology"@en ;
    dcterms:description "Classes and properties used alongside the National Skills Taxonomy concept schemes."@en ;
    owl:versionInfo "0.0.2" .

  ?s ?p ?o .
}
WHERE {
  {
    GRAPH <https://data.jobsandskills.gov.au/graph/skills-sparql/profile-input> {
      { ?s rdf:type owl:Class . }
      UNION { ?s rdf:type ?t . FILTER(?t IN (rdf:Property, owl:ObjectProperty, owl:DatatypeProperty, owl:AnnotationProperty)) }
      FILTER(STRSTARTS(STR(?s), "https://test.linked.data.gov.au/def/nst/ontology"))
      ?s ?p ?o .
    }
  }
  UNION
  {
    GRAPH <https://data.jobsandskills.gov.au/graph/skills-sparql/nst-little-schemes> {
      { ?s rdf:type owl:Class . }
      UNION { ?s rdf:type ?t . FILTER(?t IN (rdf:Property, owl:ObjectProperty, owl:DatatypeProperty, owl:AnnotationProperty)) }
      FILTER(STRSTARTS(STR(?s), "https://test.linked.data.gov.au/def/nst/ontology"))
      ?s ?p ?o .
    }
  }

  FILTER(?p IN (
    rdf:type,
    rdfs:label, rdfs:comment,
    rdfs:subClassOf, rdfs:subPropertyOf,
    rdfs:domain, rdfs:range,
    owl:equivalentClass, owl:equivalentProperty,
    owl:inverseOf,
    skos:prefLabel, skos:definition
  ))
}' \
  -o skills-schema.ttl

pylode -p ontpub skills-schema.ttl -o skills-schema.html

# 3) Scheme pages (one per concept scheme)
GRAPH="$GRAPH_PROFILE"
for IRI in \
'https://test.linked.data.gov.au/def/nst' \
'https://test.linked.data.gov.au/def/nst-cognitive-domain' \
'https://test.linked.data.gov.au/def/nst-digital-intensity' \
'https://test.linked.data.gov.au/def/nst-futureready' \
'https://test.linked.data.gov.au/def/nst-learning-context' \
'https://test.linked.data.gov.au/def/nst-level' \
'https://test.linked.data.gov.au/def/nst-nature' \
'https://test.linked.data.gov.au/def/nst-percent-range' \
'https://test.linked.data.gov.au/def/nst-transferability' \
'https://test.linked.data.gov.au/def/nst-work-context'
do
  SLUG="${IRI##*/}"
  TTL="scheme-${SLUG}.ttl"
  HTML="scheme-${SLUG}.html"

  curl -sS -H "Accept: text/turtle" "$FUSEKI/$DATASET/sparql" \
    --data-urlencode "query=
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
CONSTRUCT { <${IRI}> ?p ?o . }
WHERE { GRAPH <${GRAPH}> { <${IRI}> ?p ?o . } }" \
    -o "$TTL"

  pylode -p vocpub "$TTL" -o "$HTML"
done

# 4) Index hub
cat > skills-docs-index.html <<'HTML'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <title>Skills Graph Profile documentation</title>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; margin: 2rem; line-height: 1.4; }
    h1,h2 { margin: 0.2rem 0 0.8rem; }
    ul { padding-left: 1.2rem; }
    li { margin: 0.35rem 0; }
  </style>
</head>
<body>
  <h1>Skills Graph Profile documentation</h1>

  <h2>Profile</h2>
  <ul>
    <li><a href="skills-profile.html">Skills Graph Profile (landing page)</a></li>
  </ul>

  <h2>Ontology</h2>
  <ul>
    <li><a href="skills-schema.html">NST Ontology (classes &amp; properties)</a></li>
  </ul>

  <h2>Concept schemes</h2>
  <ul>
    <li><a href="scheme-nst.html">National Skills Taxonomy (NST)</a></li>
    <li><a href="scheme-nst-cognitive-domain.html">Skill Cognitive Level</a></li>
    <li><a href="scheme-nst-digital-intensity.html">Skill Digital Intensity</a></li>
    <li><a href="scheme-nst-futureready.html">Skill Future Readiness</a></li>
    <li><a href="scheme-nst-learning-context.html">Skill Learning Context</a></li>
    <li><a href="scheme-nst-level.html">Skill levels</a></li>
    <li><a href="scheme-nst-nature.html">Skill Nature</a></li>
    <li><a href="scheme-nst-percent-range.html">Percentage ranges</a></li>
    <li><a href="scheme-nst-transferability.html">Skill Transferability</a></li>
    <li><a href="scheme-nst-work-context.html">Skill Work Context</a></li>
  </ul>
</body>
</html>
HTML

echo "Done. Open: skills-docs-index.html"

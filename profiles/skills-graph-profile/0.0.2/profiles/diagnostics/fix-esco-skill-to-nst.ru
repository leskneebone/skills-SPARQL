PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX esco: <http://data.europa.eu/esco/model#>
PREFIX nsto: <https://test.linked.data.gov.au/def/nst/ontology#>

DELETE {
  GRAPH <https://data.jobsandskills.gov.au/graph/skills-sparql/combined> {
    ?s rdf:type esco:Skill .
  }
}
INSERT {
  GRAPH <https://data.jobsandskills.gov.au/graph/skills-sparql/combined> {
    ?s rdf:type nsto:Skill .
  }
}
WHERE {
  GRAPH <https://data.jobsandskills.gov.au/graph/skills-sparql/combined> {
    ?s rdf:type esco:Skill .
    FILTER(STRSTARTS(STR(?s), "https://test.linked.data.gov.au/def/nst/"))
  }
}

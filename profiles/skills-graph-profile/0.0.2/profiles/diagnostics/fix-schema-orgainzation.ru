PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

DELETE {
  GRAPH <https://data.jobsandskills.gov.au/graph/skills-sparql/combined> {
    ?s rdf:type <https://schema.org/Orgainzation> .
  }
}
INSERT {
  GRAPH <https://data.jobsandskills.gov.au/graph/skills-sparql/combined> {
    ?s rdf:type <https://schema.org/Organization> .
  }
}
WHERE {
  GRAPH <https://data.jobsandskills.gov.au/graph/skills-sparql/combined> {
    ?s rdf:type <https://schema.org/Orgainzation> .
  }
}

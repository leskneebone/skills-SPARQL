PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

DELETE {
  GRAPH <https://data.jobsandskills.gov.au/graph/skills-sparql/combined> {
    ?s rdf:type <http://www.w3.org/2004/02/skos/core#Concpet> .
  }
}
INSERT {
  GRAPH <https://data.jobsandskills.gov.au/graph/skills-sparql/combined> {
    ?s rdf:type <http://www.w3.org/2004/02/skos/core#Concept> .
  }
}
WHERE {
  GRAPH <https://data.jobsandskills.gov.au/graph/skills-sparql/combined> {
    ?s rdf:type <http://www.w3.org/2004/02/skos/core#Concpet> .
  }
}

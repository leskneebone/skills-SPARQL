PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

WITH <https://data.jobsandskills.gov.au/graph/skills-sparql/combined>
DELETE {
  ?s <http://www.w3.org/2004/02/skos/core#inScheme:> ?o .
  ?s <http://www.w3.org/2004/02/skos/core#altLabel:> ?o .
  ?s <http://www.w3.org/2004/02/skos/core#definition:> ?o .
  ?s <http://www.w3.org/2004/02/skos/core#prefLabel:> ?o .
  ?s <http://www.w3.org/2004/02/skos/core#Definition> ?o .
  ?s <http://www.w3.org/2004/02/skos/core#PrefLabel> ?o .
}
INSERT {
  ?s skos:inScheme ?o .
  ?s skos:altLabel ?o .
  ?s skos:definition ?o .
  ?s skos:prefLabel ?o .
  ?s skos:definition ?o .
  ?s skos:prefLabel ?o .
}
WHERE {
  {
    ?s <http://www.w3.org/2004/02/skos/core#inScheme:> ?o .
  } UNION {
    ?s <http://www.w3.org/2004/02/skos/core#altLabel:> ?o .
  } UNION {
    ?s <http://www.w3.org/2004/02/skos/core#definition:> ?o .
  } UNION {
    ?s <http://www.w3.org/2004/02/skos/core#prefLabel:> ?o .
  } UNION {
    ?s <http://www.w3.org/2004/02/skos/core#Definition> ?o .
  } UNION {
    ?s <http://www.w3.org/2004/02/skos/core#PrefLabel> ?o .
  }
}

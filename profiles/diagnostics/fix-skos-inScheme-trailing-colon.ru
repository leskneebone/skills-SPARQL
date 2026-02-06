PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

WITH <https://data.jobsandskills.gov.au/graph/skills-sparql/combined>
DELETE { ?s <http://www.w3.org/2004/02/skos/core#inScheme:> ?o . }
INSERT { ?s skos:inScheme ?o . }
WHERE  { ?s <http://www.w3.org/2004/02/skos/core#inScheme:> ?o . }

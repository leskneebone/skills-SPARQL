PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

WITH <https://data.jobsandskills.gov.au/graph/skills-sparql/combined>
DELETE { ?s <http://www.w3.org/2004/02/skos/core#prefLabel:> ?o . }
INSERT { ?s skos:prefLabel ?o . }
WHERE  { ?s <http://www.w3.org/2004/02/skos/core#prefLabel:> ?o . } .
WITH <https://data.jobsandskills.gov.au/graph/skills-sparql/combined>
DELETE { ?s <http://www.w3.org/2004/02/skos/core#altLabel:> ?o . }
INSERT { ?s skos:altLabel ?o . }
WHERE  { ?s <http://www.w3.org/2004/02/skos/core#altLabel:> ?o . } .
WITH <https://data.jobsandskills.gov.au/graph/skills-sparql/combined>
DELETE { ?s <http://www.w3.org/2004/02/skos/core#definition:> ?o . }
INSERT { ?s skos:definition ?o . }
WHERE  { ?s <http://www.w3.org/2004/02/skos/core#definition:> ?o . } .
WITH <https://data.jobsandskills.gov.au/graph/skills-sparql/combined>
DELETE { ?s <http://www.w3.org/2004/02/skos/core#inScheme:> ?o . }
INSERT { ?s skos:inScheme ?o . }
WHERE  { ?s <http://www.w3.org/2004/02/skos/core#inScheme:> ?o . } .

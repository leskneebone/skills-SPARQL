PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcat: <http://www.w3.org/ns/dcat#>

DELETE {
  GRAPH <https://data.jobsandskills.gov.au/graph/skills-sparql/combined> {
    <https://data.jobsandskills.gov.au/dataset/occupationProfiles> rdf:type dcat:Dataset .
  }
}
WHERE {
  GRAPH <https://data.jobsandskills.gov.au/graph/skills-sparql/combined> {
    <https://data.jobsandskills.gov.au/dataset/occupationProfiles> rdf:type dcat:Dataset .
  }
}

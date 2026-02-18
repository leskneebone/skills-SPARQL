PREFIX dcat:   <http://www.w3.org/ns/dcat#>
PREFIX dcterms:<http://purl.org/dc/terms/>
PREFIX rdfs:   <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd:    <http://www.w3.org/2001/XMLSchema#>

WITH <https://data.jobsandskills.gov.au/graph/skills-sparql/profile-input>

# Work Context
DELETE {
  <https://test.linked.data.gov.au/def/nst-work-context> dcat:distribution ?d .
  <https://test.linked.data.gov.au/def/nst-work-context> rdfs:seeAlso ?u .
  ?d ?dp ?do .
}
INSERT {
  <https://test.linked.data.gov.au/def/nst-work-context>
    dcat:distribution <https://test.linked.data.gov.au/def/nst-work-context#dist-ttl> ;
    rdfs:seeAlso "https://AZURE_URL_WORK_CONTEXT"^^xsd:anyURI .

  <https://test.linked.data.gov.au/def/nst-work-context#dist-ttl>
    a dcat:Distribution ;
    dcterms:title "NST Work Context (Turtle)"@en ;
    dcat:downloadURL "https://AZURE_URL_WORK_CONTEXT"^^xsd:anyURI ;
    dcat:mediaType "text/turtle" .
}
WHERE {
  OPTIONAL { <https://test.linked.data.gov.au/def/nst-work-context> dcat:distribution ?d . ?d ?dp ?do . }
  OPTIONAL { <https://test.linked.data.gov.au/def/nst-work-context> rdfs:seeAlso ?u . }
}

PREFIX dct:   <http://purl.org/dc/terms/> 
PREFIX day:   <http://reference.data.gov.uk/id/day/>
DROP SILENT GRAPH <http://reference.data.gov.uk/data/2011-09-30/union> ;
DROP SILENT DEFAULT;
INSERT {
    GRAPH <http://reference.data.gov.uk/data/2011-09-30/union> {?s ?p ?o}
} WHERE {
  {
    GRAPH ?g {
        [] dct:temporal day:2011-09-30 .
        ?s ?p ?o .
    }
  } UNION {
    GRAPH ?g {
        ?s ?p ?o .
    }
    FILTER (strStarts(str(?g), "http://reference.data.gov.uk/data/perm/"))
  }
};
COPY GRAPH <http://reference.data.gov.uk/data/2011-09-30/union> TO DEFAULT

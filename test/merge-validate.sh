# Sample query which discriminates 2013 or 2011 versions of default graph
readonly SERVICE=http://localhost:3030/ds

curl -s --data-urlencode "query@-"  $SERVICE/query <<!!
PREFIX gov:     <http://reference.data.gov.uk/def/central-government/>
PREFIX foaf:  <http://xmlns.com/foaf/0.1/> 
SELECT * WHERE
{
    <http://reference.data.gov.uk/id/public-body/environment-agency/unit/anglian-anglian-office-anglian-office> 
          gov:hasPost [ gov:heldBy ?person] .
    ?person foaf:name ?name .
}
!!
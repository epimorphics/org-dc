# Data server installation information

## Services provided

The data server provides the following services which are compatible with the existing deployments.

### Triple store

A customized installation of Apache Jena Fuseki, which hosts historic and current organogram data as RDF.  The data is structured as:

   * a merged graph for each historic period with name `http://reference.data.gov.uk/organogram/graph/{period}`
   * a merged default graph for the latest period
   * a set of per-organization graphs for at least the current period with name `http://reference.data.gov.uk/organogram/graph/{period}/filename.ttl`

In the current dev deployment two periods are present `2011-09-30` and `2013-09-30`.

### Sparql endpoint

The triple store exposes a SPARQL query endpoint at http://reference.data.gov.uk/sparql/organogram/query

### Linked data API

A linked data API front end (based on Elda with an Apache httpd front end) provides a large number of item and list API endpoints to enable access to the underlying data via a browser and in a variety of formats (RDF formats, json, xml).

For example:  http://reference.data.gov.uk/id/public-body which lists all public bodies in the dataset via the document response http://reference.data.gov.uk/doc/public-body

### API access to historic data

For compatbility with the existing deployment access to http://reference.data.gov.uk/doc/{period}/{path} will be rewritten so as to retrieve the `{path}` information from the graph of the given period, for example: http://reference.data.gov.uk/2011-09-30/doc/public-body/environment-agency

### Vocabulary files

Static vocabulary files are served from http://reference.data.gov.uk/def by the Apache httpd

### Reference time server

Provides linked data for a range of categories of time period, for example http://reference.data.gov.uk/id/year/2014 and http://reference.data.gov.uk/doc/year/2014.ttl

## Installation summary

For ease of transfer we have removed all dependencies from our own deployment and build systems and created a set of static deployable assets.

These are documented in the form of a simple Vagrant config with a shell provisioner (`bootstrap.sh`). The shell provisioning is not intended for production use, but it's a machine checkable way to write down the steps involved.

For simplicity we've taken the brutal approach of packaging up all the configuration files and static document assets as a single merged directory tree under `root`. These could be repackaged for each subsystem - Fuseki, Elda, Apache config, Apache document assets

The installation also requires a set of binary assets for the web applications, the initial database and the triple store server.

For convenience we have assembled appropriately customized versions of these in a folder in an S3 bucket: https://organograms.s3-eu-west-1.amazonaws.com/RELEASE-0.1/

The assets used are:

`./jena-fuseki-1.0.2-20140601.080328-75-distribution.tar.gz`
    stable snapsnot of Apache Jena Fuseki 1.0.2

`./organograms.war`
   customized Elda with updated Xalan processor

`./ORG-DB.tgz`
   initial database with merged graphs for 2011-09-30 and 2013-09-30 with the latter as the default

`./IntervalServer.war`
   Reference time interval service

## Scripting

The installation includes a set of sample shell scripts to support the publication process, these are in `/usr/share/lib/organograms/bin`.

`org-backup` 

Schedules a backup of the data which will generate a new backup file in `/var/lib/fuseki/backups`

`org-publish {period} {file}`

Publishes an RDF orgranogram file for a single organization to the correct graph in the triple store.  Underneath this is simply a `PUT` with the correct target URI (which is not exposed beyond firewall) and mime type so it would be possible to perform the same action directly.

`org-merge {period}`

Constructs and publishes a merged RDF graph for the given period.

This will extract from the triple store all per-department graphs for that period, plus all permanent graphs that should appear for all period. The merged data is kept as a compressed file in `/var/lib/organogram/merges`.

This merged file is then published twice - to the merge graph for that period and to the global default graph.

The script check that the merged graph is non-trivial. An empty more or a merge that is too short (just the size of the permanent graphs) will cause it to abort. The threshold for this check needs to be kept in sync with the size of permanent graphs.

The publication process for a fully populated period should take between 1 and 2 mins on a quiet server.

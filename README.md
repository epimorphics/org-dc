# Organogram Data Conversion Utility

Provides a RESTful service endpoint for converting Organogram CSV data pairs to RDF for publication.

## Service interface

To request a data conversion POST to the service endpoint (to be agreed) a multi-part mime message with the following components:

| Parameter | Type | Meaning |
|---|---|---|
| `senior-csv` | File | CSV of senior posts |
| `junior-csv` | File | CSV of junior posts |
| `release` | String | Intended release date, format 2013-09-30 |
| `basename` | String | Name for this dataset to use in URI segments, optional, defaults to filename |

This will return a 200 response with the resulting RDF file (in Turtle format) or a 400 with a text/plain payload giving a trace of the data conversion including error messages.

Example command line invocation:

    curl -i -F "release=2011-09-30" -F "senior-csv=@defra-example-junior.csv" -F "junior-csv=@defra-example-junior.csv" http://localhost:8080/convert

## Server state

The implementation is stateless and conversions are done in memory.

Application log messages will be recorded by tomcat in catalina.out as usual which tomcat will rotate.

For each conversion request a trace of the action will also be recorded in a timestamped `trace-{time}.txt` file in `/var/log/org-dc`.

## Configuration

| File | Usage |
|---|---|
| `/opt/org-dc/app.conf` | Application configuration |
| `/opt/org-dc/templates/*` | Data conversion templates |
| `/opt/org-dc/mapsources/*` | Data needed by the conversion templates |


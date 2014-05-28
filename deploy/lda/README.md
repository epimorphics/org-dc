# Organogram LDA configuration files.

This directory contains the configuration assets required to assemble and deploy
an elda installation for the organogram linked data.

- `etc/elda/conf.d/ROOT/organogram-lda-config.ttl`  
   Elda configuration file
- `lda-assets/xslts/`
  - `org.xsl`   
    Stylesheet driver for HTML renderer
  - `org-csv.xsl`  
    Stylesheet driver for csv renderer
  - `staging-org.xsl`  
    Alternative Stylesheet driver for HFML renderer which injects 'staging.js' to perform client sided URL rewriting.
- `lda-assets/scripts/staging.js`  
  Staging URL rewriter customised for reference.data.gov.uk 

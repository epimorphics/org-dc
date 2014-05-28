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

## Elda Deployment

There are several options for creating a .war file to deploy. The current configuration is set up for a `ROOT` web application deployment. However, the configuration should work as a non-`ROOT` deployment, though will have to be moved or cloned to a neighbouring directory under `/etc/elda/conf.d/'  whose name matches the context path of the deployed web application.

### Building your own .war file.

Clone the elda-starter project at https://github.com/epimorphics/elda-starter.git 

Merge/copy the `lda-assets` directory from this project over the top of the `src/main/webapp/lda-assets` directory in the newly cloned elda-starter project.

From the cloned `elda-starter` project root directory build the project:

   `mvn clean package`
   
The resulting `.war` file should turn up in the `target` directory.

### Using Elda Bundled or Elda Common and Elda Assets

There are prebuilt elda war files that cover a number of potential usages and avoid the step of having to manage a build of your own deployable web application.

These pre-build files are available in the Epimorphics public mave repo under:

      http://repository.epimorphics.com/com/epimorphics/lda/
      
At the time of writing I'd recommend the `1.2.34-SNAPSHOT` versions and preferably the `1.2.34` release that should follow.

Elda Bundled is a combination of Elda-Common and Elda-Assets as a single .war file. Unfortunately the layout of the assest bundle with Elda Bundled is currently inconsistent with common practice (which group the assets bundle in a directory named `lda-assets`).

The best approach for using these pre-build files is to unpack `elda-assets` bundle, merge in the local `lda-asset` changes/additions from this project and serve the static assets directly from a front-end apache server. This is roughly what's been done for the LR deployment.

### .war file deployment

Whether build by cloneing `elda-starter` or directly using a copy of `elda-common` the resulting .war file should be copied to:

      /var/lib/tomcat6/webapps/ROOT.war

or, with more apache config effort it can be deployed as a named webapp with a non-root context path eg.

      /var/lib/tomcat6/webapps/organogram-lda.war
      
In the latter case the `organogram-lda-config.ttl` file will need to be deployed as:

      /etc/elda/conf.d/organogram-lda/organogram-lda-config.ttl
      
Actually the local file name is irrelevant other then ending in `.ttl`
   
### LDA config

The `deploy/lda/etc` subdirectory of this project is set up to be directly copied/merged into the `/etc` directory of a Linux system. On windows it shoud be copied to `c:/etc`. As currently laid out this should give a working ROOT webapplication elda installation.

#### Config tweaks

It may be necessary to 'tweak' the configure location of the XSLT stylesheets that drive the CSV and HTML renderings to reference the *filesystem* location of the stylesheet assets. The relevant parameter supports absolute URI (eg. file: and http: URI or paths that are relative to the web application context root (even those with a leading '/' :-( ).

Strictly the XSLT assets need only be locally accessible to the webapplication container. They do not have to be accessible on the web. However the resulting HTML does make reference to other artiefacts (CSS files, scripts and image files) that do need to be web accessible. These are all contained within the `lda-assets` bundle and as configured need to be accessible at:

      http://<hostname>/lda-assets/...

The location relative to the current host be changed if necessary by changing the value of the `_resourceRoot` variable in the api configuration file. However, some apache httpd-conf magic will be neccessary if the asset bundle is separated from the Tomcat deployment.

Likewise the preconfigured SPARQL endpoint and/or its externally visible access and form URL may also need tweaking.



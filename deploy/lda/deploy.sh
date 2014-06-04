########################################################
# Install or make sure of Apache2  and Tomcat(6 or 7))
########################################################
sudo apt-get install apache2
sudo apt-get install tomcat7
########################################################
# Download, build and install intervals server
########################################################
cd workspace
svn co https://venture2.projectlocker.com/Epimorphics/skw/svn/IntervalServer/trunk IntervalServer
cd IntervalServer
mvn clean package
sudo cp target/IntervalServer.war /var/lib/tomcat7/webapps/
########################################################
# Download common elda artifacts from epi maven repo.
########################################################
cd ~
mkdir tmp
cd tmp
#wget http://repository.epimorphics.com/com/epimorphics/lda/elda-common/1.2.34-SNAPSHOT/elda-common-1.2.34-20140521.100806-2.war
wget http://repository.epimorphics.com/com/epimorphics/lda/elda-assets/1.2.34-SNAPSHOT/elda-assets-1.2.34-20140521.100640-2.war
########################################################
# Unpack common assets so that they can be served by apache.
########################################################
sudo mkdir -p /var/www/html/reference/lda-assets
cd /var/www/html/reference/lda-assets/reference/lda-assets
sudo unzip ~/tmp/elda-assets-1.2.34-20140521.100640-2.war
########################################################
# Remove a file that shouldn't be there
########################################################
sudo rm index.html
########################################################
# Clone org-dc project for associated deployable lda assets and lda config
########################################################
cd ~/git
git clone https://github.com/epimorphics/org-dc.git
#! /bin/bash
cd org-dc/deploy/lda
########################################################
# Put additional assets in place
########################################################
sudo cp -Rvf lda-assets /var/www/html/reference/
########################################################
# Put lda config in place
########################################################
sudo mkdir -p /etc/elda/conf.d/organogram
sudo cp -Rv etc/elda/conf.d/ROOT/organogram-lda-config.ttl  /etc/elda/conf.d/organogram/organogram-lda-config.ttl
########################################################
# deploy elda-common as organogram
########################################################
#cd ~/tmp
#sudo cp elda-common-1.2.34-20140521.100806-2.war /var/lib/tomcat7/webapps/organogram.war
########################################################
# In place of the commented out use of elda-common above
# pending it being updated to use xalan 2.7.1
########################################################
cd ~/git
git clone https://github.com/epimorphics/elda-starter.git
cd elda-starter
mvn clean package
sudo cp target/elda-starter.war /var/lib/tomcat7/webapps/organogram.war
########################################################
# Enable Apache Modules, install vhost config for reference.data.gov.uk
# and restart apache.
########################################################
sudo a2enmod rewrite expires proxy proxy_http cache cache_disk 
cd ~/git/org-dc/deploy/lda/apache
sudo cp reference.conf /etc/apache2/sites-available/
sudo a2dissite 000-default
sudo a2ensite reference
sudo service apache restart
########################################################
# Install Fuseki
########################################################
cd ~/tmp
wget http://repository.apache.org/content/repositories/snapshots/org/apache/jena/jena-fuseki/1.1.0-SNAPSHOT/jena-fuseki-1.1.0-20140602.140856-1-distribution.zip
sudo mkdir -p /opt/jena
cd /opt/jena
sudo unzip ~/tmp/jena-fuseki-1.1.0-20140602.140856-1-distribution.zip

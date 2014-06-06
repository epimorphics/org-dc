#!/bin/bash
set -e

readonly RELEASE=RELEASE-0.1

readonly DEBUG=

########################################################
# Bring local VM upto compatibility with dev server
########################################################

apt-get update -y
apt-get install -y curl

# Install java and tomcat - only needed for local VM tests
echo "** Installing java and tomcat"
apt-get install -y tomcat7 language-pack-en
service tomcat7 stop || true
update-rc.d tomcat7 defaults

apt-get install -y openjdk-7-jdk 
update-alternatives --set java /usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java
unlink /usr/lib/jvm/default-java
ln -s /usr/lib/jvm/java-1.7.0-openjdk-amd64 /usr/lib/jvm/default-java

########################################################
#  Apache httpd - whatever the standard recipe is
########################################################

apt-get install -y apache2
a2enmod rewrite expires proxy proxy_http cache disk_cache

########################################################
# Install pre-preprepared configuration files - brute force
# Could partition these by subsystem 
#   - apache conf  ("reference" site configuration)
#   - fuseki conf
#   - elda conf
#   - tomcat conf  (java opts and server.xml)
#   - static web assets to support elda
#
# Ideally /etc/default/fuseki and /etc/default/tomcat7
# should be templated to allow memory allocations to be
# parameterized, in grounding out our Chef templates to 
# actual files that's been lost.
########################################################

cp -a /vagrant/root/* /

a2dissite default
a2ensite reference
service apache2 restart

########################################################
# Install Apache Jena fuseki - frozen 1.0.1-SNAPSHOT
########################################################

echo "** Installing Apache jena fuseki to /usr/share"
groupadd fuseki || true
useradd -g fuseki fuseki || true

curl -4s https://s3-eu-west-1.amazonaws.com/organograms/$RELEASE/jena-fuseki-distribution.tar.gz > /tmp/jena-fuseki-distribution.tar.gz
cd /usr/share
rm -rf fuseki
tar xzf /tmp/jena-fuseki-distribution.tar.gz
mv jena-fuseki-* fuseki
chown -R fuseki:fuseki /usr/share/fuseki
ln -s /usr/share/fuseki/fuseki /etc/init.d/fuseki

# Set up logs
mkdir -p /var/log/fuseki
chown fuseki:fuseki /var/log/fuseki
ln -s /var/log/fuseki /usr/share/fuseki/logs

# Set up bootstrap database and link it to fuseki
mkdir -p /var/lib/fuseki/backups
mkdir -p /var/lib/fuseki/databases
ln -s /var/lib/fuseki/backups /usr/share/fuseki/backups

echo "** Installing bootstrap database"
# N.B. Loses any existing database!
curl -4s https://s3-eu-west-1.amazonaws.com/organograms/$RELEASE/ORG-DB.tgz > /var/lib/fuseki/backups/ORG-DB.tgz
cd /var/lib/fuseki/databases
tar zxf ../backups/ORG-DB.tgz 

chown -R fuseki:fuseki /var/lib/fuseki

service fuseki start
update-rc.d fuseki defaults

########################################################
# Install Elda API front end
########################################################

service tomcat7 stop || true

echo "** Installing Elda"
rm -rf /var/lib/tomcat7/webapps/organogram*
curl -4s https://s3-eu-west-1.amazonaws.com/organograms/$RELEASE/organogram.war > /var/lib/tomcat7/webapps/organogram.war

echo "** Installing reference time server"
rm -rf /var/lib/tomcat7/webapps/IntervalServer*
curl -4s https://s3-eu-west-1.amazonaws.com/organograms/$RELEASE/IntervalServer.war > /var/lib/tomcat7/webapps/IntervalServer.war

service tomcat7 start

########################################################
# 
########################################################

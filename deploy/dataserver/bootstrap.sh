#!/bin/bash
set -e

readonly RELEASE=RELEASE-0.1

readonly DEBUG=

########################################################
# Bring local VM upto compatibility with dev server
########################################################

if [[ -z $DEBUG ]]; then
apt-get update -y
apt-get install -y curl

# Install java and tomcat - only needed for local VM tests
echo "** Installing java and tomcat"
apt-get install -y tomcat7 language-pack-en
service tomcat7 stop || true

apt-get install -y openjdk-7-jdk 
update-alternatives --set java /usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java
unlink /usr/lib/jvm/default-java
ln -s /usr/lib/jvm/java-1.7.0-openjdk-amd64 /usr/lib/jvm/default-java
fi

########################################################
#  Apache httpd - whatever the standard recipe is
########################################################

if [[ -z $DEBUG ]]; then
apt-get install -y apache2
a2enmod rewrite expires proxy proxy_http cache disk_cache
fi

########################################################
# Install pre-preprepared configuration files - brute force
# Could partition these by subsystem 
#   - apache conf  ("reference" site configuration)
#   - fuseki conf
#   - elda conf
#   - tomcat conf  (java opts and server.xml)
#   - static web assets to support elda
########################################################

cp -a /vagrant/root/* /

if [[ -z $DEBUG ]]; then
a2dissite default
a2ensite reference
service apache2 restart
fi

########################################################
# Install Apache Jena fuseki - frozen 1.0.1-SNAPSHOT
########################################################

# TODO - separate fuseki user?

if [[ -z $DEBUG ]]; then
echo "** Installing Apache jena fuseki to /usr/share"
groupadd fuseki || true
useradd -G fuseki fuseki || true

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

# Set up bootstrap database and link it to fuseki
# N.B. Loses any existing database!
mkdir -p /var/lib/fuseki/backups
mkdir -p /var/lib/fuseki/databases
ln -s /var/lib/fuseki/backups/ /usr/share/fuseki/backups
fi

if [[ -z $DEBUG ]]; then
echo "** Installing bootstrap database"
curl -4s https://s3-eu-west-1.amazonaws.com/organograms/$RELEASE/ORG-DB.tgz > /var/lib/fuseki/backups/ORG-DB.tgz
cd /var/lib/fuseki/databases
tar zxf ../backups/ORG-DB.tgz 

chown -R fuseki:fuseki /var/lib/fuseki

service fuseki start
fi

########################################################
# Install Elda API front end
########################################################

if [[ -z $DEBUG ]]; then
service tomcat7 stop || true

echo "** Installing Elda"
rm -rf /var/lib/tomcat7/webapps/organogram*
curl -4s https://s3-eu-west-1.amazonaws.com/organograms/$RELEASE/organogram.war > /var/lib/tomcat7/webapps/organogram.war

echo "** Installing reference time server"
rm -rf /var/lib/tomcat7/webapps/IntervalServer*
curl -4s https://s3-eu-west-1.amazonaws.com/organograms/$RELEASE/IntervalServer.war > /var/lib/tomcat7/webapps/IntervalServer.war

service tomcat7 stop || true
service tomcat7 start
fi

########################################################
# 
########################################################

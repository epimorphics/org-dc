##!/bin/bash
set -e

RELEASE=/vagrant/org-dc-0.0.1-SNAPSHOT.war

apt-get update -y
apt-get install -y curl

# install and configure tomcat
echo "** Installing java and tomcat"
apt-get install -y tomcat7 language-pack-en
service tomcat7 stop

# tomcat7 on ubuntu seems hardwired to java-6 so have to dance around this
# installing java-7 first doesn't work and we end up with failures in tomcat startup
apt-get install -y openjdk-7-jdk 
update-alternatives --set java /usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java
unlink /usr/lib/jvm/default-java
ln -s /usr/lib/jvm/java-1.7.0-openjdk-amd64 /usr/lib/jvm/default-java

if [ $(java -version 2>&1 | grep 1.7. -c) -ne 1 ]
then
  echo "**   ERROR: java version doesn't look right, try manual alternatives setting restart tomcat7"
  echo "**   java version is:"
  java -version
  exit 1
fi
service tomcat7 start
update-rc.d tomcat7 defaults

if [ ! -d "/opt/org-dc" ]; then
    mkdir /opt/org-dc
    chown tomcat7 /opt/org-dc
fi
if [ ! -d "/var/opt/org-dc" ]; then
    mkdir /var/opt/org-dc
    chown tomcat7 /var/opt/org-dc
fi

# If the static org-dc area is not already set up then clone from the vagrant synced folder
if [ ! -d "/opt/org-dc/conf" ]; then
  cp -R /vagrant/org-dc/* /opt/org-dc
  chown -R  tomcat7 /opt/org-dc/*
fi

if [ ! -d "/var/log/org-dc" ]; then
  mkdir /var/log/org-dc
  chown tomcat7 /var/log/org-dc
fi

# Set up configuration area /opt/org-dc
echo "** Installing registry application"
rm -rf /var/lib/tomcat7/webapps/ROOT* 
cp $RELEASE /var/lib/tomcat7/webapps/ROOT.war

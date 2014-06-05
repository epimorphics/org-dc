# Data server layout and notes

## Fuseki

Fuseki user

Installation from dist:
   /usr/share/fuseki

Note backups and databases.

/etc/init.d/fuseki -> /usr/share/fuseki/fuseki

System config:
   /etc/default/fuseki

Server config:
   /etc/fuseki/config.ttl

## Install database before startup

   /var/lib/fuseki/databases

## Elda

War from dist

Assets
   /var/www/html   from tgz in dist
   include robots.txt?

Config
   /etc/elda/conf.d/org/org.ttl

## Ref time server
   war from dist

## Apache

Config file

   /var/www/html entries for vocabularies

## Management scripts

   /usr/share/organograms/bin

## merge action

   - lock
   - drop period graph
   - construct merge of individual period graphs to file in
      /var/lib/organogram/merges
   - put to period graph
   - put to default graph
   - unlock
   


      
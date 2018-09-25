#!/bin/bash

if [ -z "$1" ]
then
        echo "Usage $0 destinationFolder";
                exit
fi

ZIMBRA_VERSION="$(echo "$(su - zimbra -c 'zmcontrol -v')" | sed 's/[\.| |, ]/_/g')"
ZIMBRA_HOST="$(su - zimbra -c 'zmhostname')"
DOMS="$(su - zimbra -c 'zmprov -l gad')" 
COSS="$(su - zimbra -c 'zmprov -l gac')" 
SERVERS="$(su - zimbra -c 'zmprov -l gas')"
echo $ZIMBRA_VERSION
echo $ZIMBRA_HOST
echo $DOMS

IFS=$','
folders='/opt/zimbra/conf,/opt/zimbra/httpd/cgi-bin,/opt/zimbra/httpd/htdocs,/opt/zimbra/jetty/webapps/zimbra,/opt/zimbra/ssl,/opt/zimbra/zimlets-deployed,/opt/zimbra/postfix/conf,/opt/zimbra/jetty/etc'
for i in $folders; do
        if [ -d "$i" ]; then
                echo "Copying $i to $1/$ZIMBRA_VERSION"
                rsync -aHRLx $i $1/$ZIMBRA_VERSION
        fi
done
unset IFS;

crontab -l > $1/$ZIMBRA_VERSION/crontab_root
cp /etc/init.d/zimbra $1/$ZIMBRA_VERSION/init.d.zimbra

su - zimbra -c "postconf ">  $1/$ZIMBRA_VERSION/postconf
su - zimbra -c "zmprov gacf ">  $1/$ZIMBRA_VERSION/globalpre
su - zimbra -c "zmlocalconfig -s " >  $1/$ZIMBRA_VERSION/localpre
for server in $SERVERS; do
  su - zimbra -c "zmprov gs -e $server " >  $1/$ZIMBRA_VERSION/server.$server
done
for dom in $DOMS; do
  su - zimbra -c "zmprov gd -e $dom " >  $1/$ZIMBRA_VERSION/domain.$dom 
done
for cos in $COSS; do
  su - zimbra -c "zmprov gc $cos " >  $1/$ZIMBRA_VERSION/cos.$cos
done
su - zimbra -c "crontab -l " >  $1/$ZIMBRA_VERSION/crontab_zimbra



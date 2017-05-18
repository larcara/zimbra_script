root@zimbra725:~# cat setup_dnsmasq.sh
#/bin/bash


if [ "$(whoami)" != 'root' ]; then
        echo $"You have no permission to run $0 as non-root user. Use sudo"
                exit 1;
fi

apt-get install libgmp10 libperl5.* unzip pax sysstat sqlite3 dnsmasq wget libaio1
DNSMASQ_CONF=/etc/dnsmasq.d/zimbra.conf
HOSTNAME=$(hostname)
HOSTIP=$(ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1)
echo "$HOSTIP  $HOSTNAME.zimbra.local $HOSTNAME" >> /etc/hosts
echo "server=$HOSTIP" >> $DNSMASQ_CONF
echo "domain=zimbra.local" >> $DNSMASQ_CONF
echo "mx-host=zimbra.local, $HOSTNAME.zimbra.local, 5" >> $DNSMASQ_CONF
echo "mx-host=$HOSTNAME.zimbra.local, $HOSTNAME.zimbra.local, 5" >> $DNSMASQ_CONF
echo "listen-address=127.0.0.1" >> $DNSMASQ_CONF
service dnsmasq restart

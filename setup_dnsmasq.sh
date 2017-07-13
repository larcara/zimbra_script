#/bin/bash

if [ "$(whoami)" != 'root' ]; then
        echo $"You have no permission to run $0 as non-root user. Use sudo"
                exit 1;
fi

apt-get install libgmp10 libperl5.* unzip pax sysstat sqlite3 dnsmasq wget libaio1
DNSMASQ_CONF=/etc/dnsmasq.d/zimbra.conf
HOSTNAME=$(hostname)
HOSTIP=$(hostname -I)
echo "$HOSTIP  $HOSTNAME.zimbra.local $HOSTNAME" >> /etc/hosts

echo "conf-dir=/etc/dnsmasq.d" >> /etc/dnsmasq.conf

echo "server=$HOSTIP" >> $DNSMASQ_CONF
echo "domain=zimbra.local" >> $DNSMASQ_CONF
echo "mx-host=$HOSTNAME, $HOSTNAME.zimbra.local, 5" >> $DNSMASQ_CONF
echo "mx-host=zimbra.local, $HOSTNAME.zimbra.local, 5" >> $DNSMASQ_CONF
echo "listen-address=127.0.0.1" >> $DNSMASQ_CONF

echo "nameserver 127.0.0.1" > /etc/resolv.conf
echo "nameserver 8.8.8.8" > /etc/resolv.conf


echo 
service dnsmasq restart
mkdir -p /opt/sw
cd /opt/sw
wget http://download.zextras.com/zextras_suite-latest.tgz &
case `lsb_release -rs` in
"16.04") wget https://files.zimbra.com/downloads/8.7.11_GA/zcs-8.7.11_GA_1854.UBUNTU16_64.20170531151956.tgz;
"14.04") wget https://files.zimbra.com/downloads/8.7.9_GA/zcs-8.7.9_GA_1794.UBUNTU14_64.20170505054622.tgz;;
"12.04") wget https://files.zimbra.com/downloads/8.7.9_GA/zcs-8.7.9_GA_1794.UBUNTU12_64.20170505054622.tgz;;
esac



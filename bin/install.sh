#!/bin/sh
groupadd -g 500 nsmgmt
useradd -u 500 -c "Nsmgmt account to run stuff" nsmgmt

dbpath=/opt/dbs/checkin.sqlite3
dname=`dirname $dbpath`
mkdir -p $dname
chmod 777 $dname
touch $dbpath
chmod 666 $dbpath
chown -R nsmgmt:nsmgmt $dname

cat <<EOF > './config.json'
{
    "dbpath" : "$dbpath"
}
EOF

npm install


allowfrom="128.111.100.0/23"
echo "-A INPUT -m state --state NEW -m tcp -p tcp --dport 3000:3005 -s $allowfrom -j ACCEPT"

svc=/usr/lib/systemd/system
if [ -d $svc ]; then
    echo "cp svc/node-checkin-master.service $svc"
    cp svc/node-checkin-master.service $svc
    
    systemctl daemon-reload
    systemctl enable node-checkin-master
    systemctl start node-checkin-master
fi
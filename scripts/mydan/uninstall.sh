#!/bin/bash

if [ -f /opt/mydan/.lock ]; then
    echo "The mydan is locked"
    exit;
fi

OS=$(uname)
ARCH=$(uname -m)

for T in "Linux:x86_64" 
do
    o=$(echo $T|awk -F: '{print $1}')
    a=$(echo $T|awk -F: '{print $2}')
    [ "X$OS" == "X$o" ] && [ "X$ARCH" == "X$a" ]&&  break
done

if [ "X$OS" == "X$o" ] && [ "X$ARCH" == "X$a" ]; then
    curl -s https://raw.githubusercontent.com/MYDan/perl/master/scripts/uninstall.sh |bash || exit 1
fi

curl -s https://raw.githubusercontent.com/MYDan/openapi/master/scripts/mayi/uninstall.sh |bash || exit

echo mydan uninstall OK

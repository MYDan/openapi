#!/bin/bash

if [ -f /opt/mydan/.lock ]; then
    echo "The mydan is locked"
    exit;
fi

OS=$(uname)
ARCH=$(uname -m)

for T in "Linux:x86_64" "Darwin:x86_64"
do
    o=$(echo $T|awk -F: '{print $1}')
    a=$(echo $T|awk -F: '{print $2}')
    [ "X$OS" == "X$o" ] && [ "X$ARCH" == "X$a" ]&&  break
done

if [ "X$OS" == "X$o" ] && [ "X$ARCH" == "X$a" ]; then
    echo "OS:$OS ARCH:$ARCH ok"
else
    echo "OS:$OS ARCH:$ARCH Not supported"
    exit 1
fi


if [ "X$OS" == "XDarwin" ]; then
    echo "$OS perl not need to uninstall"
else
    curl -s https://raw.githubusercontent.com/MYDan/perl/master/scripts/uninstall.sh |bash
fi

curl -s https://raw.githubusercontent.com/MYDan/openapi/master/scripts/mayi/uninstall.sh |bash

#!/bin/bash

if [ -f /opt/mydan/.lock ]; then
    echo "The mydan is locked"
    exit;
fi

OS=$(uname)
ARCH=$(uname -m)

checktool() {
    if ! type $1 >/dev/null 2>&1; then
        echo "Need tool: $1"
        exit 1;
    fi
}

for T in "Linux:x86_64"
do
    o=$(echo $T|awk -F: '{print $1}')
    a=$(echo $T|awk -F: '{print $2}')
    [ "X$OS" == "X$o" ] && [ "X$ARCH" == "X$a" ]&&  break
done

if [ "X$OS" == "X$o" ] && [ "X$ARCH" == "X$a" ]; then
    curl -s https://raw.githubusercontent.com/MYDan/perl/master/scripts/install.sh |bash
else
    checktool cpan   
    cpan install MYDan
fi

curl -s https://raw.githubusercontent.com/MYDan/openapi/master/scripts/mayi/install.sh |bash

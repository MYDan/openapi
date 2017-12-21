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

checktool() {
    if ! type $1 >/dev/null 2>&1; then
        echo "Need tool: $1"
        exit 1;
    fi
}

if [ "X$OS" == "XDarwin" ]; then
    checktool cpan   
    cpan install MYDan
else
    curl -s https://raw.githubusercontent.com/MYDan/perl/master/scripts/update.sh |bash
fi

curl -s https://raw.githubusercontent.com/MYDan/openapi/master/scripts/mayi/update.sh |bash

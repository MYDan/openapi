#!/bin/bash

if [ -f /opt/mydan/.lock ]; then
    echo "The mydan is locked"
    exit;
fi

curl -k -s https://raw.githubusercontent.com/MYDan/perl/master/scripts/install.sh |bash || exit 1
curl -k -s https://raw.githubusercontent.com/MYDan/openapi/master/scripts/mayi/install.sh |bash || exit 1

echo mydan install OK

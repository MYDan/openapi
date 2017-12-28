#!/bin/bash

if [ -f /opt/mydan/.lock ]; then
    echo "The mydan is locked"
    exit;
fi

curl -s https://raw.githubusercontent.com/MYDan/perl/master/scripts/install.sh |bash || exit 1
curl -s https://raw.githubusercontent.com/MYDan/openapi/master/scripts/mayi/install.sh |bash || exit

echo mydan install OK

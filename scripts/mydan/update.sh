#!/bin/bash

if [ -f /opt/mydan/.lock ]; then
    echo "The mydan is locked"
    exit;
fi

curl -k -s https://raw.githubusercontent.com/MYDan/perl/master/scripts/update.sh |bash || exit 1
curl -k -s https://raw.githubusercontent.com/MYDan/openapi/master/scripts/mayi/update.sh |bash || exit 1

echo mydan update OK

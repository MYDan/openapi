#!/bin/bash

if [ -f /opt/mydan/.lock ]; then
    echo "The mydan is locked"
    exit;
fi

curl -s https://raw.githubusercontent.com/MYDan/perl/master/scripts/update.sh |bash
curl -s https://raw.githubusercontent.com/MYDan/openapi/master/scripts/mayi/update.sh |bash

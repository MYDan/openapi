#!/bin/bash

if [ -f /opt/mydan/.lock ]; then
    echo "The mydan is locked"
    exit;
fi

export MYDAN_REPO_PUBLIC="http://180.153.186.60 http://223.166.174.60"
#MYDAN_REPO_PRIVATE

curl -k -s https://raw.githubusercontent.com/MYDan/perl/master/scripts/uninstall.sh |bash || exit 1
curl -k -s https://raw.githubusercontent.com/MYDan/openapi/master/scripts/mayi/uninstall.sh |bash || exit 1

echo mydan uninstall OK

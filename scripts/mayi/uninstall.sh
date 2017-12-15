#!/bin/bash

BP=/opt/mydan
if [ -f $BP/dan/.lock ]; then
    echo "The mydan is locked"
    exit;
fi

$BP/dan/bootstrap/bin/bootstrap --uninstall
rm -rf $BP/{bin,box,dan,etc,var,tmp}

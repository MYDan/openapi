#!/bin/bash

INSTALLERDIR=/opt/mydan
if [ -f $INSTALLERDIR/dan/.lock ]; then
    echo "The mayi is locked"
    exit;
fi

$INSTALLERDIR/dan/bootstrap/bin/bootstrap --uninstall
rm -rf $INSTALLERDIR/{bin,box,dan,etc,var,tmp}

echo mayi uninstall OK

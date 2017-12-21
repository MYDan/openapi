#!/bin/bash

INSTALLERDIR='/opt/mydan'

if [ -f $INSTALLERDIR/dan/.lock ]; then
    echo "The mayi is locked"
    exit;
fi

mkdir -p $INSTALLERDIR/etc

> $INSTALLERDIR/etc/env.tmp
if [ -n "$ORGANIZATION" ];then
    echo "ORGANIZATION=$ORGANIZATION" >> $INSTALLERDIR/etc/env.tmp
fi

if [ -n "$MYDAN_KEY_UPDATE" ];then
    echo "MYDAN_KEY_UPDATE=$MYDAN_KEY_UPDATE" >> $INSTALLERDIR/etc/env.tmp
fi

if [ -n "$MYDAN_PROC_UPDATE" ];then
    echo "MYDAN_PROC_UPDATE=$MYDAN_PROC_UPDATE" >> $INSTALLERDIR/etc/env.tmp
fi
if [ -n "$MYDAN_WHITELIST_UPDATE" ];then
    echo "MYDAN_WHITELIST_UPDATE=$MYDAN_WHITELIST_UPDATE" >> $INSTALLERDIR/etc/env.tmp
fi

if [ -n "$MYDAN_UPDATE" ];then
    echo "MYDAN_UPDATE=$MYDAN_UPDATE" >> $INSTALLERDIR/etc/env.tmp
fi

if [[ -s $INSTALLERDIR/etc/env.tmp ]];then
    mv $INSTALLERDIR/etc/env.tmp $INSTALLERDIR/etc/env
else
    rm $INSTALLERDIR/etc/env
    rm $INSTALLERDIR/etc/env.tmp
fi


if [ -f $INSTALLERDIR/etc/env ];then
    $INSTALLERDIR/dan/bootstrap/bin/bootstrap --install
else
    $INSTALLERDIR/dan/bootstrap/bin/bootstrap --uninstall
fi

echo mayi env OK

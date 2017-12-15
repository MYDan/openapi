#!/bin/bash

BP='/opt/mydan'

mkdir -p $BP/etc

> $BP/etc/env.tmp
if [ -n "$ORGANIZATION" ];then
    echo "ORGANIZATION=$ORGANIZATION" >> $BP/etc/env.tmp
fi

if [ -n "$MYDAN_KEY_UPDATE" ];then
    echo "MYDAN_KEY_UPDATE=$MYDAN_KEY_UPDATE" >> $BP/etc/env.tmp
fi

if [ -n "$MYDAN_PROC_UPDATE" ];then
    echo "MYDAN_PROC_UPDATE=$MYDAN_PROC_UPDATE" >> $BP/etc/env.tmp
fi
if [ -n "$MYDAN_WHITELIST_UPDATE" ];then
    echo "MYDAN_WHITELIST_UPDATE=$MYDAN_WHITELIST_UPDATE" >> $BP/etc/env.tmp
fi

if [ -n "$MYDAN_UPDATE" ];then
    echo "MYDAN_UPDATE=$MYDAN_UPDATE" >> $BP/etc/env.tmp
fi

if [[ -s $BP/etc/env.tmp ]];then
    mv $BP/etc/env.tmp $BP/etc/env
else
    rm $BP/etc/env
    rm $BP/etc/env.tmp
fi


if [ -f $BP/etc/env ];then
    $BP/dan/bootstrap/bin/bootstrap --install
else
    $BP/dan/bootstrap/bin/bootstrap --uninstall
fi

echo OK

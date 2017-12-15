#!/bin/bash

BU='https://github.com/MYDan/mayi/archive'
VU='https://raw.githubusercontent.com/MYDan/openapi/master/scripts/mayi/version'
BP='/opt/mydan'

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


if [ -d "$BP/dan" ]; then
    echo 'Already installed'
    exit  
fi

version=$(curl -s $VU)

if [[ $version =~ ^[0-9]{14}$ ]];then
    echo "version: $version"
else
    echo "get version fail"
    exit;
fi

wget -O mayi.$version.tar.gz $BU/mayi.$version.tar.gz

tar -zxvf mayi.$version.tar.gz

cd mayi-mayi.$version

/opt/mydan/perl/bin/perl Makefile.PL
make
make install dan=1 box=1 def=1

cd -
rm -rf mayi-mayi.$version
rm -f mayi.$version.tar.gz

echo $version > $BP/dan/.version

if [ -f $BP/etc/env ];then
    /opt/mydan/dan/bootstrap/bin/bootstrap --install
fi

echo OK

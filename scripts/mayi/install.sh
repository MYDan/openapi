#!/bin/bash

MAYIURL='https://github.com/MYDan/mayi/archive'
VERSIONURL='https://raw.githubusercontent.com/MYDan/openapi/master/scripts/mayi/version'
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
    rm -f $INSTALLERDIR/etc/env
    rm -f $INSTALLERDIR/etc/env.tmp
fi


if [ -d "$INSTALLERDIR/dan" ]; then
    echo 'Already installed'
    exit  
fi

version=$(curl -s $VERSIONURL)

if [[ $version =~ ^[0-9]{14}$ ]];then
    echo "version: $version"
else
    echo "get version fail"
    exit;
fi

wget -O mayi.$version.tar.gz $MAYIURL/mayi.$version.tar.gz

tar -zxvf mayi.$version.tar.gz

cd mayi-mayi.$version

/opt/mydan/perl/bin/perl Makefile.PL
make
make install dan=1 box=1 def=1

cd -
rm -rf mayi-mayi.$version
rm -f mayi.$version.tar.gz

echo $version > $INSTALLERDIR/dan/.version

if [ -f $INSTALLERDIR/etc/env ];then
    $INSTALLERDIR/dan/bootstrap/bin/bootstrap --install
fi

echo OK

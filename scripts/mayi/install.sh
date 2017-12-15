#!/bin/bash

BU='https://github.com/MYDan/mayi/archive'
VU='https://raw.githubusercontent.com/MYDan/openapi/master/scripts/mayi/version'
BP='/opt/mydan'

> $BP/etc/env.tmp
if [ -n "$MYDAN_KEY_UPDATE" ];then
    echo "MYDAN_KEY_UPDATE=$MYDAN_KEY_UPDATE" >> $BP/etc/env.tmp
fi
if [ -n "$MYDAN_UPDATE" ];then
    echo "MYDAN_UPDATE=$MYDAN_UPDATE" >> $BP/etc/env.tmp
fi
mv $BP/etc/env.tmp $BP/etc/env

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

echo OK

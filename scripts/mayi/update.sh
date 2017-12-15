#!/bin/bash

BU='https://github.com/MYDan/mayi/archive'
VU='https://raw.githubusercontent.com/MYDan/openapi/master/scripts/mayi/version'
BP='/opt/mydan'

if [ ! -d "$BP/dan" ]; then
    echo 'Not yet installed'
fi

version=$(curl -s $VU)

if [[ $version =~ ^[0-9]{14}$ ]];then
    echo "version: $version"
else
    echo "get version fail"
    exit;
fi

localversion=$(cat /$BP/dan/.version )

if [ "X$localversion" == "X$version" ]; then
    echo "It's the latest version";
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

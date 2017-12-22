#!/bin/bash

MAYIURL='https://github.com/MYDan/mayi/archive'
VERSIONURL='https://raw.githubusercontent.com/MYDan/openapi/master/scripts/mayi/version'
INSTALLERDIR='/opt/mydan'

if [ -f $INSTALLERDIR/dan/.lock ]; then
    echo "The mayi is locked"
    exit;
fi

if [ ! -d "$INSTALLERDIR/dan" ]; then
    echo 'Not yet installed'
fi

checktool() {
    if ! type $1 >/dev/null 2>&1; then
        echo "Need tool: $1"
        exit 1;
    fi
}

checktool curl
checktool wget
checktool tar
checktool cat
checktool head

version=$(curl -s $VERSIONURL)

if [[ $version =~ ^[0-9]{14}$ ]];then
    echo "mayi version: $version"
else
    echo "get version fail"
    exit;
fi

localversion=$(cat $INSTALLERDIR/dan/.version )

# loop thru available well known Perl installations
for PERL in "/opt/mydan/perl/bin/perl" "/usr/bin/perl" "/usr/local/bin/perl"
do
    [ -x "$PERL" ] && echo "Using Perl $PERL" && break
done
if [ ! -x "$PERL" ]; then
  echo "Need /opt/mydan/perl/bin/perl /usr/bin/perl or /usr/local/bin/perl to use $0"
  exit 1
fi

localperl=$(head -n 1 $INSTALLERDIR/dan/tools/range )

if [ "X$localversion" == "X$version" ] && [ "X$localperl" == "X#!$PERL" ]; then
    echo "This is the latest version of Mayi";
    exit 1;
fi

LOCALINSTALLER=$(mktemp mayi.XXXXXX)
clean_exit () {
    [ -f $LOCALINSTALLER ] && rm $LOCALINSTALLER
    [ -d mayi-mayi.$version ] && rm -rf mayi-mayi.$version
    exit $1
}

wget -O $LOCALINSTALLER $MAYIURL/mayi.$version.tar.gz || clean_exit 1

tar -zxvf $LOCALINSTALLER || clean_exit 1

cd mayi-mayi.$version || clean_exit 1

$PERL Makefile.PL || clean_exit 1
make  || clean_exit 1
make install dan=1 box=1 def=1 || clean_exit 1

cd - || clean_exit 1

rm -rf mayi-mayi.$version
rm -f $LOCALINSTALLER

echo $version > $INSTALLERDIR/dan/.version

echo mayi update OK

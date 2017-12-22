#!/bin/bash

MAYIURL='https://github.com/MYDan/mayi/archive'
VERSIONURL='https://raw.githubusercontent.com/MYDan/openapi/master/scripts/mayi/version'
INSTALLERDIR='/opt/mydan'

checktool() {
    if ! type $1 >/dev/null 2>&1; then
        echo "Need tool: $1"
        exit 1;
    fi
}

checktool curl
checktool wget
checktool tar

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
    echo "mayi version: $version"
else
    echo "get version fail"
    exit;
fi

clean_exit () {
    [ -f $LOCALINSTALLER ] && rm $LOCALINSTALLER
    [ -d mayi-mayi.$version ] && rm -rf mayi-mayi.$version
    exit $1
}

LOCALINSTALLER=$(mktemp mayi.XXXXXX)

wget -O $LOCALINSTALLER $MAYIURL/mayi.$version.tar.gz || clean_exit 1

tar -zxvf $LOCALINSTALLER || clean_exit 1

cd mayi-mayi.$version || clean_exit 1


# loop thru available well known Perl installations
for PERL in "/opt/mydan/perl/bin/perl" "/usr/bin/perl" "/usr/local/bin/perl"
do
    [ -x "$PERL" ] && echo "Using Perl $PERL" && break
done

if [ ! -x "$PERL" ]; then
  echo "Need /opt/mydan/perl/bin/perl /usr/bin/perl or /usr/local/bin/perl to use $0"
  clean_exit 2
fi

$PERL Makefile.PL || clean_exit 1
make || clean_exit 1
make install dan=1 box=1 def=1 || clean_exit 1

cd - || clean_exit 1

rm -rf mayi-mayi.$version
rm -f $LOCALINSTALLER

echo "$version" > $INSTALLERDIR/dan/.version

if [ -f $INSTALLERDIR/etc/env ];then
    $INSTALLERDIR/dan/bootstrap/bin/bootstrap --install
fi

echo mayi install OK

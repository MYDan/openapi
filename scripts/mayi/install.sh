#!/bin/bash

MAYIURL='https://github.com/MYDan/mayi/archive'
VERSIONURL='https://raw.githubusercontent.com/MYDan/openapi/master/scripts/mayi/version'
INSTALLERDIR='/opt/mydan'

checktool() {
    if ! type $1 >/dev/null 2>&1; then
        echo "Need tool: $1"
        exit 1
    fi
}

checktool curl
checktool wget
checktool tar
checktool make
checktool rsync
checktool md5sum

if [ -f $INSTALLERDIR/dan/.lock ]; then
    echo "The mayi is locked"
    exit 1;
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

VVVV=$(curl -k -s $VERSIONURL)
version=$(echo $VVVV|awk -F: '{print $1}')
md5=$(echo $VVVV|awk -F: '{print $2}')

if [[ $version =~ ^[0-9]{14}$ ]];then
    echo "mayi version: $version"
else
    echo "get version fail"
    exit 1
fi

clean_exit () {
    [ -f $LOCALINSTALLER ] && rm $LOCALINSTALLER
    [ -d mayi-mayi.$version ] && rm -rf mayi-mayi.$version
    exit $1
}


get_repo ()
{
    ALLREPO=$1
    C=${#ALLREPO[@]}

    DF=/tmp/x.$$.tmp
    mkfifo $DF
    exec 1000<>$DF
    rm -f $DF

    for((n=1;n<=$C;n++))
    do
        echo >&1000
    done

    for((i=0;i<$C;i++))
    do
        read -u1000
        {
            s=$(curl -k --connect-timeout 2 -I ${ALLREPO[$i]}/mayi.$version.tar.gz 2>/dev/null|head -n 1|awk '/302|200/'|wc -l)
            echo "$i:$s" >&1000
        }&
    done

    wait

    for((i=1;i<=$C;i++))
    do
        read -u1000 X
        id=$(echo $X|awk -F: '{print $1}')
        s=$(echo $X|awk -F: '{print $2}')
        if [[ "x1" == "x$s" && "x" == "x$ID" ]];then
            ID=$id
        fi
    done

    exec 1000>&-
    exec 1000<&-

    if [ "X$ID" != "X" ];then
        MYDan_REPO=${ALLREPO[$ID]}
    fi
}

if [[ ! -z $MYDAN_REPO_PRIVATE ]];then
    MYDAN_REPO=$(echo $MYDAN_REPO_PRIVATE |xargs -n 1|awk '{print $0"/mayi/data"}'|xargs -n 100)
    ALLREPO=( $MYDAN_REPO )
    get_repo $ALLREPO
fi

if [ -z $MYDan_REPO ];then
    MYDAN_REPO=$(echo $MYDAN_REPO_PUBLIC|xargs -n 1|awk '{print $0"/mayi/data"}'|xargs -n 100)
    ALLREPO=( $MAYIURL $MYDAN_REPO )
    get_repo $ALLREPO
fi

if [ -z "$MYDan_REPO" ];then
    echo "nofind mayi.$version.tar.gz on all repo"
    exit 1
else
    PACKTAR="$MYDan_REPO/mayi.$version.tar.gz"
fi

LOCALINSTALLER=$(mktemp mayi.XXXXXX)

wget --no-check-certificate -O $LOCALINSTALLER "$PACKTAR" || clean_exit 1

fmd5=$(md5sum $LOCALINSTALLER|awk '{print $1}')
if [ "X$md5" != "X$fmd5" ];then
    echo "mayi $version md5 nomatch"
    exit 1
fi

tar -zxvf $LOCALINSTALLER || clean_exit 1

cd mayi-mayi.$version || clean_exit 1


PERL=$INSTALLERDIR/perl/bin/perl

if [ ! -x "$PERL" ]; then
  echo "no find $PERL"
  clean_exit 1
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

if [ ! -e /bin/mydan ];then
    ln -fsn $INSTALLERDIR/bin/mydan /bin/mydan
fi

echo mayi install OK

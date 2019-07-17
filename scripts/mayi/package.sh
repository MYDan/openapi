#!/bin/bash

MAYIURL='https://github.com/MYDan/mayi/archive'
VERSIONURL='https://raw.githubusercontent.com/MYDan/openapi/master/scripts/mayi/version'

checktool() {
    if ! type $1 >/dev/null 2>&1; then
        echo "Need tool: $1"
        exit 1
    fi
}

checktool curl
checktool wget
checktool head
checktool md5sum

if [ "X$MYDanInstallLatestVersion" == "X1" ]; then
    VVVV="00000000000000:00000000000000000000000000000000"
else
    VVVV=$(curl -k -s $VERSIONURL)
fi

version=$(echo $VVVV|awk -F: '{print $1}')
md5=$(echo $VVVV|awk -F: '{print $2}')

if [[ $version =~ ^[0-9]{14}$ ]];then
    echo "mayi version: $version"
else
    echo "get version fail"
    exit 1
fi

if [ -f "mydan.mayi.$version" ]; then
    echo "mydan.mayi.$version already exists"
    exit 0
fi

LOCALINSTALLER=$(mktemp mayi.XXXXXX)
clean_exit () {
    [ -f $LOCALINSTALLER ] && rm $LOCALINSTALLER
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
    #exit 1
    PACKTAR="$MAYIURL/mayi.$version.tar.gz"
else
    PACKTAR="$MYDan_REPO/mayi.$version.tar.gz"
fi

wget --no-check-certificate -O $LOCALINSTALLER "$PACKTAR" || clean_exit 1

if [ "X$md5" != "X00000000000000000000000000000000" ];then
    fmd5=$(md5sum $LOCALINSTALLER|awk '{print $1}')
    if [ "X$md5" != "X$fmd5" ];then
        echo "mayi $version md5 nomatch"
        exit 1;
    fi
fi

mv $LOCALINSTALLER mydan.mayi.$version || clean_exit 1

echo mayi package OK

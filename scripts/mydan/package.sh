#!/bin/bash
set -e

#export MYDAN_REPO_PUBLIC="http://180.153.186.60 http://223.166.174.60"
#MYDAN_REPO_PRIVATE

LIST=("Linux:x86_64" "Linux:i686" "CYGWIN_NT-6.1:x86_64" "FreeBSD:amd64" "FreeBSD:i386")

if [ "X$1" != "X" ];then
    for T in "${LIST[@]}"
    do
        O=$T
        [ "X$T" == "X$1" ] && break
    done

    if [ "X$1" != "X$O" ];then
        echo "$1 Not supported !"
        echo "${LIST[@]}"
        echo ERROR
        exit 1
    fi
    LIST=( $1 )
fi


for T in "${LIST[@]}"
do
	curl -k -s https://raw.githubusercontent.com/MYDan/perl/master/scripts/package.sh |bash -s $T|| exit 1
done

curl -k -s https://raw.githubusercontent.com/MYDan/openapi/master/scripts/mayi/package.sh |bash || exit 1


packageInstall=packageInstall.sh
if [ ! -f $packageInstall ]; then
    wget --no-check-certificate -O  $packageInstall "https://raw.githubusercontent.com/MYDan/openapi/master/scripts/mydan/packageInstall.sh" || exit 1
fi

mkdir -p key
cp /opt/mydan/etc/agent/auth/*.pub key/

for M in `ls mydan.mayi.*`
do
	mayiVersion=$(echo $M|awk -F. '{print $3}')
	if [[ $mayiVersion =~ ^[0-9]{14}$ ]];then
    	echo "mayi version: $mayiVersion"
        for T in "${LIST[@]}"
        do
            OS=$(echo $T|awk -F: '{print $1}')
            ARCH=$(echo $T|awk -F: '{print $2}')
            LCID=$(echo $T|awk -F: '{print $3}')
            if [[ "X$ARCH" == "X" ]];then
                echo "no find ARCH"
                exit 1
            fi
			DIST=$OS.$ARCH
            if [[ "X$LCID" != "X" ]];then
				DIST=$OS.$ARCH.$LCID
            fi
			tar -zcvf mydan.package.$mayiVersion.$DIST mydan.mayi.$mayiVersion  mydan.perl.$DIST key
			/opt/mydan/dan/tools/xtar --script $packageInstall --package  mydan.package.$mayiVersion.$DIST --output  mydan.agent.$mayiVersion.$DIST
        done
	else
    	echo "[Warn]get version fail"
	fi
done

echo mydan package OK

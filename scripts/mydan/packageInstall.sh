#!/bin/bash

INFO=$(echo $0|sed  's/.*mydan.agent.//'|sed 's/.run.*//')

version=$(echo $INFO|awk -F. '{print $1}')
FOS=$(echo $INFO|awk -F. '{print $2}')
FARCH=$(echo $INFO|awk -F. '{print $3}')
FLCID=$(echo $INFO|awk -F. '{print $4}')

LOS=$(uname)  
LARCH=$(uname -m)

checktool() {
    if ! type $1 >/dev/null 2>&1; then
        echo "Need tool: $1"
        exit 1;
    fi
}

checktool tar
checktool head
checktool make

LLCID=""
if [ "X$OS" == "XLinux" ] && [ "X$ARCH" == "Xx86_64" ]; then
     checktool ldd
     LDDVERSION=$(ldd --version|head -n 1)
     if [ "X$LDDVERSION" == "Xldd (GNU libc) 2.5" ];then
         LCID="2.5"
     fi
fi


if [[ "X$FOS" == "X$LOS" ]] && [[ "X$FARCH" == "X$LARCH" ]] && [[ "X$FLCID" == "X$LLCID" ]];then
    echo OS: $FOS ARCH: $FARCH 
else
    echo "nomatch FOS: $FOS FARCH: $FARCH FLCID: $FLCID <=> LOS: $LOS LARCH: $LARCH LLCID: $LLCID"
    echo "ERROR"
    exit 1
fi
	

TMPPATH=/tmp/mydan.install.temp
INSTALLERDIR='/opt/mydan' 

clean_exit () {
    rm -rf $TMPPATH
    echo  "ERROR"
    exit $1
}

mkdir -p $TMPPATH
tar -zxvf $TMP -C $TMPPATH || clean_exit 1

if [ -f $INSTALLERDIR/perl/.lock ]; then
    echo "The perl is locked"
    exit 1;
fi

DIST=mydan.perl.$FOS.$FARCH

if [ "X$FLCID" != "X" ]; then
    DIST=mydan.perl.$FOS.$FARCH.$FLCID
fi

LOCALINSTALLER=$TMPPATH/$DIST

if [ ! -e $INSTALLERDIR ]; then
    mkdir -p $INSTALLERDIR
fi

tar -zxf $LOCALINSTALLER -C $INSTALLERDIR || clean_exit 1

echo perl update OK

if [ -f $INSTALLERDIR/dan/.lock ]; then
    echo "The mayi is locked"
    exit 1
fi

LOCALINSTALLER=$TMPPATH/mydan.mayi.$version
tar -zxvf $LOCALINSTALLER -C $TMPPATH || clean_exit 1

cd $TMPPATH/mayi-mayi.$version || clean_exit 1

PERL=$INSTALLERDIR/perl/bin/perl

if [ ! -x "$PERL" ]; then
  echo "no find $PERL"
  clean_exit 1
fi

$PERL Makefile.PL || clean_exit 1
make  || clean_exit 1
make install dan=1 box=1 def=1 || clean_exit 1

cd - || clean_exit 1

rm -rf $TMPPATH

echo $version > $INSTALLERDIR/dan/.version

if [ ! -e /bin/mydan ];then
    ln -fsn $INSTALLERDIR/bin/mydan /bin/mydan
fi

echo mayi update OK

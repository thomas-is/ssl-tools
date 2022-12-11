#!/bin/sh

LABEL="local"
SYS="/usr/share/ca-certificates/$LABEL"

if [ "$( whoami )" != "root" ] ; then
  echo "Must be root!"
fi

BASE=$( realpath $( dirname $0 ) )

. $BASE/helpers.sh

flyCheck

if [ ! -f "$1" ] ; then
  CERTS="$BASE/certs"
else
  CERTS="$( realpath $2 )"
fi

echo "Using $CERTS"

mkdir -p $SYS
cp $CERTS/*.pem $SYS/

sed "/^$LABEL.*/d" -i /etc/ca-certificates.conf

echo "$( ls -1 $CERTS/*.pem | rev | cut -f1 -d"/" | rev | sed "s/.*/$LABEL\/&/" )" | tee -a /etc/ca-certificates.conf
update-ca-certificates

#!/bin/sh

base=$( realpath $( dirname $0 ) )

. $base/include.sh

if [ "$( whoami )" != "root" ] ; then
  ko "you must be root"
  exit 1
fi

require update-ca-certificates || exit 1

label="local"
ca="/usr/share/ca-certificates/$label"

certs="$base/certs"
info "using $certs"

mkdir -p $ca
cp $certs/*.pem $ca/

sed "/^$label.*/d" -i /etc/ca-certificates.conf

echo "$( basename -a $( ls -1 $certs/*.pem ) | sed "s/.*/$label\/&/" )" \
  | tee -a /etc/ca-certificates.conf

update-ca-certificates

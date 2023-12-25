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

rm -rf $ca
sed "/^$label.*/d" -i /etc/ca-certificates.conf
update-ca-certificates -f

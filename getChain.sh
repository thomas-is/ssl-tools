#!/bin/sh

base=$( realpath $( dirname $0 ) )

. $base/include.sh

if [ $# -ne 1 ] ; then
  echo "Usage: $0 FQDN"
  exit 1
fi

require openssl curl || exit 1

domain="$1"
certs="$base/certs"

mkdir -p $certs || exit 1
info "Using $certs"

pem="$certs/$domain.pem"
if domainPEM $domain > $pem; then
  ok "$( basename $pem) ($( daysLeft $pem ) days left)"
else
  ko "$( basename $pem)"
  exit 1
fi

while [ "$( issuerURL $pem )" != "" ]
do
  tab="$tab  "
  issuer="$( issuerName $pem )"
  url="$( issuerURL $pem )"
  crt="$certs/$issuer.crt"
  curl -s $url --output $crt
  pem="$( echo "$crt" | sed 's/crt$/pem/g' )"
  openssl x509 -inform $( format $crt ) -outform PEM -in $crt > $pem
  ok "$tab$( basename $pem) ($( daysLeft $pem ) days left)"
done

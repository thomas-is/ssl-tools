#!/bin/sh

BASE=$( realpath $( dirname $0 ) )

. $BASE/helpers.sh

flyCheck

if [ "$1" = "" ] ; then
  echo "Usage: $0 FQDN [cert dir]"
  exit 1
fi

DOMAIN="$1"

if [ ! -f "$2" ] ; then
  CERTS="$BASE/certs"
else
  CERTS="$( realpath $2 )"
fi

echo "Using $CERTS"
mkdir -p $CERTS


PEM="$CERTS/$DOMAIN.pem"
printf "$( fileName $PEM)"
domainPEM $DOMAIN > $PEM
echo " - $( daysLeft $PEM ) days left"

while [ "$( issuerURL $PEM )" != "" ]
do

  T="$T  "

  ISSUER="$( issuerName $PEM )"
  URL="$( issuerURL $PEM )"
  CRT="$CERTS/$ISSUER"

  curl -s $URL --output $CRT

  PEM="$CRT.pem"
  printf "$T$( fileName $PEM)"
  openssl x509 -inform $( format $CRT ) -outform PEM -in $CRT > $PEM
  echo " - $( daysLeft $PEM ) days left"
done

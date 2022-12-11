#!/bin/sh

flyCheck() {
  for DEP in update-ca-certificates openssl curl
  do
    if [ "$( which $DEP )" = "" ] ; then
      echo "Fatal: can't find $DEP"
      exit 1
    fi
  done
}

fileName() {
  echo $1 | rev | sed 's/\/.*$//g' | rev
}

format() {
  cat -v $1 | grep -q "\^@" && echo "DSR" || echo "PEM"
}


domainPEM() {
  DOMAIN="$1"
  echo \
    | openssl s_client -connect $DOMAIN:443 -showcerts 2> /dev/null \
    | openssl x509 -outform pem
}

daysLeft() {
  UNIX_END="$( date +"%s" -d "$( openssl x509 -noout -enddate -in $1 -inform $( format $1 ) \
    | sed 's/^notAfter=//g' | sed 's/ GMT$//g' )")"
  UNIX_NOW="$( date +"%s")"
  UNIX_LEFT="$(( $UNIX_END - $UNIX_NOW ))"
  echo "$(( $UNIX_LEFT / 3600 / 24 ))"
}



issuerName() {
  ISSUER_FULL="$( openssl x509 -in $1 -inform $( format $1 ) -noout -issuer )"

  ISSUER_O="$( echo "$ISSUER_FULL" \
    | sed 's/^.*O = //g' \
    | sed 's/,.*$//g' \
    | tr -c -d '[0-9A-Za-z]' )"

  ISSUER_CN="$( echo "$ISSUER_FULL" \
    | sed 's/^.*CN = //g' \
    | sed 's/,.*$//g' \
    | tr -c -d '[0-9A-Za-z]' )"

  echo "${ISSUER_O}_${ISSUER_CN}"

}

issuerURL() {
  CERTFILE="$1"
  openssl x509 -in $1 -inform $( format $1 ) -noout -text \
    | grep -i "CA Issuer" \
    | sed 's/^.*http/http/g'
}

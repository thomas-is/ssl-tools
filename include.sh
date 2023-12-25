#!/bin/sh

ko() {
  printf "[\033[1;31m\033mfail\033[0m\033m] %s\n" "$@" > /dev/stderr
}
ok() {
  printf "[\033[1;32m\033m ok \033[0m\033m] %s\n" "$@" > /dev/stderr
}
warn() {
  printf "[\033[1;33m\033mwarn\033[0m\033m] %s\n" "$@" > /dev/stderr
}
info() {
  printf "[\033[1;34m\033minfo\033[0m\033m] %s\n" "$@" > /dev/stderr
}

require() {
  missing=0
  for dep in $@
  do
    if [ "$( which $dep )" = "" ] ; then
      ko "missing $dep"
      missing=1
    fi
  done
  if [ $missing -ne 0 ] ; then
    exit 1
  fi
}

format() {
  cat -v $1 | grep -q "\^@" && echo "DSR" || echo "PEM"
}

domainPEM() {
  domain="$1"
  echo \
    | openssl s_client -connect $domain:443 -showcerts 2> /dev/null \
    | openssl x509 -outform pem 2> /dev/null
  [ $? -eq 0 ]
}

daysLeft() {
  end="$( date +"%s" -d "$( openssl x509 -noout -enddate -in $1 -inform $( format $1 ) \
    | sed 's/^notAfter=//g' | sed 's/ GMT$//g' )")"
  now="$( date +"%s")"
  left="$(( $end - $now ))"
  echo "$(( $left / 3600 / 24 ))"
}

issuerName() {
  issuer="$( openssl x509 -in $1 -inform $( format $1 ) -noout -issuer )"

  o="$( echo "$issuer" \
    | sed 's/^.*O = //g' \
    | sed 's/,.*$//g' \
    | tr -c -d '[0-9A-Za-z]' )"

  cn="$( echo "$issuer" \
    | sed 's/^.*CN = //g' \
    | sed 's/,.*$//g' \
    | tr -c -d '[0-9A-Za-z]' )"

  echo "${o}_${cn}"

}

issuerURL() {
  openssl x509 -in $1 -inform $( format $1 ) -noout -text \
    | grep -i "CA Issuer" \
    | sed 's/^.*http/http/g'
}

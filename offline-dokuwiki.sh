#!/bin/bash
# authors: 
# 20110221 written by samlt / https://www.dokuwiki.org/tips:offline-dokuwiki.sh
# 20180529 modified by jeremie.francois@gmail.com (remove broken/useless navigation, more dom cleanup via sed)
# 

# default values
DEF_HOSTNAME=mydoku.wiki.lan
#DEF_LOCATION=path/to/start
DEF_LOCATION=fullindex
USERNAME=
PASSWORD=
PROTO=http
DEF_DEPTH=2
ADDITIONNAL_WGET_OPTS=${AWO}
PROGNAME=${0##*/}
HEADER="<div>This is an offline copy of <a href='%HOSTNAME%'>%HOSTNAME%</a>. It may be obsolete and some links may be broken.</div>"
FOOTER="<footer>Cloned on $(date)</footer>"
PREFIX='auto'

show_help() {
   cat<<EOT

NAME
   $PROGNAME: make an offline export of a dokuwiki documentation

SYNOPSIS
   $PROGNAME options

OPTIONS
   --login      username
   --passwd     password
   --ms-filenames
   --https
   --depth      number
   --hostname   doku.host.tld
   --location   path/to/start
   --header     raw html content to add after <body>
   --footer     raw html content to add before </body> (do not use @ caracters)
   --prefix     path to store files into (do not use @ caracters). Default is date-host.

NOTES
   if not specified on the command line
      * username and password are empty
      * hostname defaults to '$DEF_HOSTNAME'
      * location defaults to '$DEF_LOCATION'

EOT
}

while [ $# -gt 0 ]; do
   case "$1" in
      --login)
         shift
         USERNAME=$1
         ;;
      --passwd)
         shift
         PASSWORD=$1
         ;;
      --hostname)
         shift
         HOST=$1
         ;;
      --depth)
         shift
         DEPTH=$1
         ;;
      --location)
         shift
         LOCATION=$1
         ;;
      --https)
         PROTO=https
         ;;
      --ms-filenames)
         ADDITIONNAL_WGET_OPTS="$ADDITIONNAL_WGET_OPTS --restrict-file-names=windows"
         ;;
      --header)
         shift
         FOOTER="$1"
		;;
      --footer)
         shift
         FOOTER="$1"
		;;
      --prefix)
         shift
         PREFIX="$1"
		;;
      --help)
         show_help
         exit
         ;;
   esac
   shift
done

: ${DEPTH:=$DEF_DEPTH}
: ${HOST:=$DEF_HOSTNAME}
: ${LOCATION:=$DEF_LOCATION}

[[ "$PREFIX" == "auto" ]] && PREFIX="$(date +'%Y%m%d')-$HOST"

url="$PROTO://$HOST/$LOCATION"

echo "[WGET] downloading: start: http://$HOSTNAME/$LOCATION (login/passwd=${USERNAME:-empty}/${PASSWORD:-empty})"

wget  --no-verbose \
      --recursive \
      --level="$DEPTH" \
      --execute robots=off \
      --no-parent \
      --page-requisites \
      --convert-links \
      --http-user="$USERNAME" \
      --http-password="$PASSWORD" \
      --auth-no-challenge \
      --adjust-extension \
      --exclude-directories=_detail,_export \
      --reject="feed.php*,*do=*,*indexer.php?id=*" \
      --directory-prefix="$PREFIX" \
      --no-host-directories \
      $ADDITIONNAL_WGET_OPTS \
      "$url"

HEADER=$(echo "$HEADER" | sed "s#%HOSTNAME%#$url#")
FOOTER=$(echo "$FOOTER" | sed "s#%HOSTNAME%#$url#")

echo
echo "[SED] fixing links(href...) in the HTML sources: ${PREFIX}/${LOCATION%/*}/*.html"

sed -i -e 's#href="\([^:]\+:\)#href="./\1#g' \
       -e "s#\(indexmenu_\S\+\.config\.urlbase='\)[^']\+'#\1./'#" \
       -e "s#\(indexmenu_\S\+\.add('[^']\+\)#\1.html#" \
       -e "s#\(indexmenu_\S\+\.add([^,]\+,[^,]\+,[^,]\+,[^,]\+,'\)\([^']\+\)'#\1./\2.html'#" \
       -e "s#<link[^>]*do=[^>]*>##g" \
       -e "s#<a href.*\?do=.*\?</a>##g" \
       -e "/<nav/,/<\/nav>/d" \
       -e "/<footer/,/<\/footer>/d" \
       -e "s@^<body\(.*\)@<body\1 $HEADER@" \
       -e "s@</body>@$FOOTER</body>@" \
       ${PREFIX}/${LOCATION%/*}/*.html

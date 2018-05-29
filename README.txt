
NAME
   offline-dokuwiki.sh: make an offline export of a dokuwiki documentation

SYNOPSIS
   offline-dokuwiki.sh options

OPTIONS
   --login      username
   --passwd     password
   --ms-filenames download only windows-compatible filenames
   --https      use https instead of http
   --depth      number
   --hostname   doku.host.tld
   --location   path/to/start
   --header     raw html content to add after <body> (do not use @ caracters)
   --footer     raw html content to add before </body> (do not use @ caracters)
   --prefix     path to store files into. Default is date-host.

NOTES
   if not specified on the command line
      * username and password are empty
      * hostname defaults to 'mydoku.wiki.lan'
      * location defaults to 'doku.php?id=start'


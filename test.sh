#!/bin/sh

   set -- a "--volume" "/tmp/my dir:/data"

   declare -a bad=${@:2:${#@}}
   printf '<%s>\n' "${bad[@]}"
   # can become:
   # <--volume>
   # </tmp/my>
   # <dir:/data>
   
   
   set -- a "--volume" "/tmp/my dir:/data"

   shift
   printf '<%s>\n' "$@"
   # <--volume>
   # </tmp/my dir:/data>

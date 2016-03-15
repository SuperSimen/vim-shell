#! /bin/bash

while read line
do
  echo "$line"
  vim --servername TEST --remote-send ":silent call PrintLine('$line') | echo <CR>"
done < "${1:-/dev/stdin}"

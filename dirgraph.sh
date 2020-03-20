#!/usr/bin/env bash
# Operating systems - project01
# author: sabina gulcikova
#        <xgulci00@stud.fit.vutbr.cz>
# date: 15/03/20

#predefined condition
export POSIXLY_CORRECT=yes
IFS=' '
regex=''
normalisation=0

#current directory
DIR=$(pwd)
#number of directories
ND=0
#number of files
NF=0

#behaviour following the arguments
while getopts "i:n" arguments; do
  case "$arguments" in
      i)
        regex=$optarg
        ;;
      n)
        normalisation=1
        ;;
      *)
        echo "error: invalid argument" >&2
        exit 1
        ;;
  esac
done

#zadany adresar
assigndir="."
if [ $# -eq 1 ]; then
  assigndir=${!OPTIND}
fi

#skontrolovat, ci adresar existuje
if [ -d "$assigndir" ]; then
  #pokial zadany adresar nie je aktualnym, zmenime ho
  if [ "$assigndir" != "$DIR" ]; then
    DIR=${!OPTIND}
  fi
  #adresar neexistuje
else
  echo "error: the directory does not exist" >&2
  exit 1
fi

function temp {
  nOfFiles=0
  while read -r line; do
      nOfFiles=$((nOfFiles+1))
  done
  echo $nOfFiles
}

function temp2 {
  nOfFolders=0
  while read -r line; do
    echo $line
    if [ -d "$line" ]; then
        nOfFolders=$((nOfFolders+1))
    fi
  #echo $nOfFolders
  done
}
#prechadzanie suborov
#normalizacia
#ignorovanie suborov
echo "Root directory: $DIR"

 find "$DIR" -type f -ls | awk '{print substr($0, index($0,$11))}' | temp2
echo $DIR
find "$DIR" -type f -ls | temp | {
  read -r allFiles
  NF=$allFiles
  echo "All files: $NF"
}

echo "File size histogram:"

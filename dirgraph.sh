#!/bin/sh
# Operating systems - project01
# author: sabina gulcikova
#        <xgulci00@stud.fit.vutbr.cz>
# date: 15/03/20

#predefined conditions
export POSIXLY_CORRECT=yes
IFS=' '
regex=''
normalisation=0
regexFlag=0

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
        regexFlag=1
        ;;
      n)
        normalisation=1
        ;;
      *)
        >&2 echo "error: invalid argument"
        exit 1
        ;;
  esac
done

#---------------------------------------------#
#------------Initial precautions--------------#

#validity of arguments check
(( OPTIND-- ))
shift $OPTIND

#invalid number of arguments
if [ $# -gt 1 ]; then
  >&2 echo "error: invalid number of arguments"
  exit 1
fi

#valid number of arguments
if [ $# -eq 1 ]; then
  DIR="$1"
fi

#checking whether given directory exists
if [ ! -d "$DIR" ]; then
  >&2 echo "error: given directory does not exist"
  exit 1
fi

#regular expression check
if [ $regexFlag -eq 1 ]; then
  #presence of regex
  #check validity of the regular expression

  #check whether regex covers the root directory
  if echo "$DIR" | grep -qE "$regex"; then
    >&2 echo "error: regular expression covers the root directory"
    exit 1
  fi
fi

#---------------------------------------------#
#if regex
#prechadzame vsetkymi subormi
#nacitame riadok
#vyhovuje regexu? -> continue
#inak -> files++
#je directory?
#ak ano -> folders++

#ak nie je zadany regex
#prechadzame subormi
#nacitame riadok, files++
#je subor? folders++

function getFiles {
  nOfFiles=0
  while read -r line; do
      nOfFiles=$((nOfFiles+1))
  done
  echo $nOfFiles
}

echo "Root directory: $DIR"

#find "$DIR" -type f -ls | awk '{print substr($0, index($0,$11))}' | getFolders
#echo $DIR
# find "$DIR" -type f -ls | getFolders | {
#   read -r allFolders
#   ND=$allFolders
#   echo "All directories: $ND"
# }

#recursively gets the number of all directories
ls -lR "$DIR" | grep ^d | wc -l | {
  read -r allFolders
  ND=$allFolders
  echo "Directories: $ND"
}

#recursively gets the number of all files
ls -lR "$DIR" | grep ^- | wc -l | {
  read -r allFiles
  NF=$allFiles
  echo "All files: $NF"
}

echo "File size histogram:"

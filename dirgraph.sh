#!/bin/sh
# Operating systems - project01
# author: sabina gulcikova
#        <xgulci00@stud.fit.vutbr.cz>
# date: 15/03/20

#predefined conditions
export POSIXLY_CORRECT=yes
IFS=' '
regex=''
regexFlag=0
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
#-------------histogram variables-------------#

lessTh100B=0
lessTh1KiB=0
lessTh10Kib=0
lessTh100Kib=0
lessTh1Mib=0
lessTh10Mib=0
lessTh100Mib=0
lessTh1Gib=0
greaterEq1Gib=0

#---------------------------------------------#
#-----------------Functions-------------------#

function getFiles {
  nOfFiles=0
  while read -r line; do
      nOfFiles=$((nOfFiles+1))
  done
  echo $nOfFiles
}

#finds the number of files of particular size

filter() {
  size=$1
  if [ "$size" -lt 100 ]; then
    lessTh100B=$((lessTh100B+1));
  elif [ "$size" -lt 1024 ]; then
    lessTh1KiB=$((lessTh1KiB+1));
  elif [ "$size" -lt 10240 ]; then
    lessTh10Kib=$((lessTh10Kib+1));
  elif [ "$size" -lt 102400 ]; then
    lessTh100Kib=$((lessTh100Kib+1));
  elif [ "$size" -lt 1048576 ]; then
    lessTh1Mib=$((lessTh1Mib+1));
  elif [ "$size" -lt 10485760 ]; then
    lessTh10Mib=$((lessTh10Mib+1));
  elif [ "$size" -lt 104857600 ]; then
    lessTh100Mib=$((lessTh100Mib+1));
  elif [ "$size" -lt 1073741824 ]; then
    lessTh1Gib=$((lessTh1Gib+1));
  elif [ "$size"  -ge 1073741824 ]; then
    greaterEq1Gib=$((greaterEq1Gib+1));
  fi
}

# function filter_names {
#   if [ $regexFlag -eq 0 ]; then
#     cat
#     return
#   fi
#
#   while read -r line; do
#     echo $line | awk '{print $7}' | {
#         read -r check
#       if [[ ! $check =~ $regex ]]; then
#         echo "$line"
#       fi
#     }
# }

#---------------------------------------------#

#displays the root directory
echo "Root directory: $DIR"

#find "$DIR" -type f -ls | awk '{print substr($0, index($0,$11))}' | getFolders
#echo $DIR
# find "$DIR" -type f -ls | getFolders | {
#   read -r allFolders
#   ND=$allFolders
#   echo "All directories: $ND"
# }

#no directories are to be ignored
if [ "$regexFlag" -eq 0 ]; then

  #recursively gets the number of all directories
  # echo "Directories:$(find "$DIR" -type d -ls | wc -l)"
  ls -lR "$DIR" | grep ^d | wc -l | {
    read -r allFolders
    ND=$allFolders
    ND=$((ND+1))
    echo "Directories: $ND"
  }

  #recursively gets the number of all files (even the hidden ones)
  ls -lR -la "$DIR" | grep ^- | wc -l | {
    read -r allFiles
    NF=$allFiles
    echo "All files: $NF"
  }
index=0

tmp=$(find "$DIR" -type f -ls | egrep -v '^d' | awk '{print $7}')
  index="$tmp"
  #echo ">>> $index"

#while read line; do echo "LINE: '${line}'"; done <<< "$index"
while read line; do filter $line; done <<< "$index"

echo "File size histogram:"
echo "  <100 B: $lessTh100B"
echo "  <1 KiB: $lessTh1KiB"
echo "  <10 KiB: $lessTh10Kib"
echo "  <100 KiB: $lessTh100Kib"
echo "  <1 MiB: $lessTh1Mib"
echo "  <10 MiB: $lessTh10Mib"
echo "  <100 MiB: $lessTh100Mib"
echo "  <1 GiB: $lessTh1Gib"
echo "  >=1 GiB: $greaterEq1Gib"


# find "$DIR" -type f -ls | awk '{printf $7}' | {
#   read -r line
#   echo "$line "
# }

fi


#echo "File size histogram:"

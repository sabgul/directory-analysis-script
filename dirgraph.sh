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

##histogram variables
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
function filter_size {
   while read -r line; do
    echo "$line" | awk '{printf $7}' | {
      read -r size
      if [ $size -lt 100 ]; then
        ((lessTh100B=lessTh100B+1))
        echo "$lessTh100B"
      elif [ $size -lt 1024 ]; then
        echo "lol2"
        lessTh1KiB=$((lessTh1KiB+1))
      elif [ $size -lt 10240 ]; then
        echo "lol3"
        lessTh10Kib=$((lessTh10Kib+1))
      elif [ $size -lt 102400 ]; then
        echo "lol4"
        lessTh100Kib=$((lessTh100Kib+1))
      elif [ $size -lt 1048576 ]; then
        echo "lol5"
        lessTh1Mib=$((lessTh1Mib+1))
      elif [ $size -lt 10485760 ]; then
        echo "lol6"
        lessTh10Mib=$((lessTh10Mib+1))
      elif [ $size -lt 104857600 ]; then
        echo "lol7"
        lessTh100Mib=$((lessTh100Mib+1))
      elif [ $size -lt 1073741824 ]; then
        echo "lol8"
        lessTh1Gib=$((lessTh1Gib+1))
      elif [ $size -ge 1073741824 ]; then
        echo "lol9"
        greaterEq1Gib=$((greaterEq1Gib+1))
      fi
    }
  done
}

#---------------------------------------------#
  # echo "1.: $lessTh100B"
  # echo "2.: $lessTh1KiB"
  # echo "3.: $lessTh10Kib"
  # echo "4.: $lessTh100Kib"
  # echo "5.: $lessTh1Mib"
  # echo "6.: $lessTh10Mib"
  # echo "7.: $lessTh100Mib"
  # echo "8.: $lessTh1Gib"
  # echo "9.: $greaterEq1Gib"

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
  ls -lR "$DIR" | grep ^d | wc -l | {
    read -r allFolders
    ND=$allFolders
    ND=$((ND + 1))
    echo "Directories: $ND"
  }

  #recursively gets the number of all files
  ls -lR "$DIR" | grep ^- | wc -l | {
    read -r allFiles
    NF=$allFiles
    echo "All files: $NF"
  }

  #counts the number of files of particular size
find "$DIR" -type f -ls |  {
while read -r line; do
 echo "$line" | awk '{printf $7}' | {
   read -r size
   if [ "$size" -lt 100 ]; then
     ((lessTh100B=lessTh100B+1))
     echo "$lessTh100B"
   elif [ "$size" -lt 1024 ]; then
     echo "lol2"
     lessTh1KiB=$((lessTh1KiB+1))
   elif [ "$size" -lt 10240 ]; then
     echo "lol3"
     lessTh10Kib=$((lessTh10Kib+1))
   elif [ "$size" -lt 102400 ]; then
     echo "lol4"
     lessTh100Kib=$((lessTh100Kib+1))
   elif [ "$size" -lt 1048576 ]; then
     echo "lol5"
     lessTh1Mib=$((lessTh1Mib+1))
   elif [ "$size" -lt 10485760 ]; then
     echo "lol6"
     lessTh10Mib=$((lessTh10Mib+1))
   elif [ "$size" -lt 104857600 ]; then
     echo "lol7"
     lessTh100Mib=$((lessTh100Mib+1))
   elif [ "$size" -lt 1073741824 ]; then
     echo "lol8"
     lessTh1Gib=$((lessTh1Gib+1))
   elif [ "$size" -ge 1073741824 ]; then
     echo "lol9"
     greaterEq1Gib=$((greaterEq1Gib+1))
   fi
 }
done
}
echo "1.: $lessTh100B"
echo "2.: $lessTh1KiB"
echo "3.: $lessTh10Kib"
echo "4.: $lessTh100Kib"
echo "5.: $lessTh1Mib"
echo "6.: $lessTh10Mib"
echo "7.: $lessTh100Mib"
echo "8.: $lessTh1Gib"
echo "9.: $greaterEq1Gib"

fi


echo "File size histogram:"

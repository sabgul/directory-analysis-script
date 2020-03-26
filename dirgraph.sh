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
normalisationFlag=0
maximum=0

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
        regex="$OPTARG"
        regexFlag=1
        ;;
      n)
        normalisationFlag=1
        ;;
      *)
          echo "error: invalid argument" 1>&2
        exit 1
        ;;
  esac
done

#---------------------------------------------#
#------------Initial precautions--------------#
#validity of arguments check
shift $((OPTIND-1))

#invalid number of arguments
if [ $# -gt 1 ]; then
    echo "error: invalid number of arguments" 1>&2
  exit 1
fi

#valid number of arguments
if [ $# -eq 1 ]; then
  DIR="$1"
fi

#checking whether given directory exists
if [ ! -d "$DIR" ]; then
    echo "error: given directory does not exist" 1>&2
  exit 1
fi

#regular expression check
if [ $regexFlag -eq 1 ]; then
  #check whether regex covers the root directory
  if echo "${DIR##*/}" | grep -qE "$regex"; then
      echo "error: regular expression covers the root directory" 1>&2
    exit 1
  fi
fi
#---------------------------------------------#
#-------------Histogram variables-------------#

lessTh100B=0
lessTh1KiB=0
lessTh10KiB=0
lessTh100KiB=0
lessTh1MiB=0
lessTh10MiB=0
lessTh100MiB=0
lessTh1GiB=0
greaterEq1GiB=0

#---------------------------------------------#
#-----------------Functions-------------------#

# getFiles() {
#   nOfFiles=0
#   while read -r line; do
#       nOfFiles=$((nOfFiles+1))
#   done
#   echo $nOfFiles
# }

#finds the number of files of particular size
filter() {
  size=$1
  if [ "$size" -lt 100 ]; then
    lessTh100B=$((lessTh100B+1));
  elif [ "$size" -lt 1024 ]; then
    lessTh1KiB=$((lessTh1KiB+1));
  elif [ "$size" -lt 10240 ]; then
    lessTh10KiB=$((lessTh10KiB+1));
  elif [ "$size" -lt 102400 ]; then
    lessTh100KiB=$((lessTh100KiB+1));
  elif [ "$size" -lt 1048576 ]; then
    lessTh1MiB=$((lessTh1MiB+1));
  elif [ "$size" -lt 10485760 ]; then
    lessTh10MiB=$((lessTh10MiB+1));
  elif [ "$size" -lt 104857600 ]; then
    lessTh100MiB=$((lessTh100MiB+1));
  elif [ "$size" -lt 1073741824 ]; then
    lessTh1GiB=$((lessTh1GiB+1));
  elif [ "$size"  -ge 1073741824 ]; then
    greaterEq1GiB=$((greaterEq1GiB+1));
  fi
}

#function finds maximum for the purpose of normalisation
findMaximum() {
  if [ "$lessTh100B" -gt "$maximum" ]; then
    maximum=$lessTh100B
  fi
  if [ "$lessTh1KiB" -gt "$maximum" ]; then
    maximum=$lessTh1KiB
  fi
  if [ "$lessTh10KiB" -gt "$maximum" ]; then
    maximum=$lessTh10KiB
  fi
  if [ "$lessTh100KiB" -gt "$maximum" ]; then
    maximum=$lessTh100KiB
  fi
  if [ "$lessTh1MiB" -gt "$maximum" ]; then
    maximum=$lessTh1MiB
  fi
  if [ "$lessTh10MiB" -gt "$maximum" ]; then
    maximum=$lessTh10MiB
  fi
  if [ "$lessTh100MiB" -gt "$maximum" ]; then
    maximum=$lessTh100MiB
  fi
  if [ "$lessTh1GiB" -gt "$maximum" ]; then
    maximum=$lessTh1GiB
  fi
  if [ "$greaterEq1GiB" -gt "$maximum" ]; then
    maximum=$greaterEq1GiB
  fi
}

#adjusts the values according to the max/width ratio
# for the purpose of normalisation
normalise() {
  width=$1
  maximum=$2
  lessTh100B=$((lessTh100B*width/maximum))
  lessTh1KiB=$((lessTh1KiB*width/maximum))
  lessTh10KiB=$((lessTh10KiB*width/maximum))
  lessTh100KiB=$((lessTh100KiB*width/maximum))
  lessTh1MiB=$((lessTh1MiB*width/maximum))
  lessTh10MiB=$((lessTh10MiB*width/maximum))
  lessTh100MiB=$((lessTh100MiB*width/maximum))
  lessTh1GiB=$((lessTh1GiB*width/maximum))
  greaterEq1GiB=$((greaterEq1GiB*width/maximum))
}

#evaluates files and directories to be ignored
ignoreFolder() {
  directory=$1
  # echo ">>>DIR:$directory"
  # echo "$directory" | grep -v "$regex" | wc -l | {
  #   read -r allFolders
  #   ND=$((ND+1))
  # }
  # echo "Directories: $ND"
  if [[ "$directory"  =~ $regex ]];then
    return
  else
    ND=$((ND+1))
    # echo "Directories: $ND"
  fi
}

#draws number of hashes according to the number of files
hashPut() {
  total=$1
  index=0
  while [ $index -lt "$total" ]; do
    printf "#"
    index=$((index+1))
  done
  printf "\n"
}

#---------------------------------------------#
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
  ls -lR "$DIR" | grep ^d | wc -l | {
    read -r allFolders
    ND=$allFolders
    ND=$((ND+1))
    echo "Directories: $ND"
  }

  #recursively gets the number of all files (including the hidden ones)
  ls -lR -la "$DIR" | grep ^- | wc -l | {
    read -r allFiles
    NF=$allFiles
    echo "All files: $NF"
  }

  #gets the sizes of all files within the folder
  #size=$(find "$DIR" -type f -ls | grep -E -v '^d' | awk '{print $7}')
  find "$DIR" -type f -ls | grep -E -v '^d' | awk '{print $7}' | {
    while read -r size; do
      filter "$size"
    done

    #---------------------------------------------#
    #---------------Normalisation-----------------#

    if [ "$normalisationFlag" -eq 1 ]; then
      findMaximum
      #if done within terminal window
      if [ -t 1 ]; then
        width=$(tput cols);
        width=$((width-13))
      else
        width="79-12"
      fi

      #if maximum exceeds the width of the window, values are adjusted
      if [ "$maximum" -gt "$width" ]; then
        normalise "$width" "$maximum"
      fi
    fi

    #---------------------------------------------#
    #-------------Statistics display--------------#

    echo "File size histogram:"
    printf "  <100 B  : ";hashPut $lessTh100B
    printf "  <1 KiB  : ";hashPut $lessTh1KiB
    printf "  <10 KiB : ";hashPut $lessTh10KiB
    printf "  <100 KiB: ";hashPut $lessTh100KiB
    printf "  <1 MiB  : ";hashPut $lessTh1MiB
    printf "  <10 MiB : ";hashPut $lessTh10MiB
    printf "  <100 MiB: ";hashPut $lessTh100MiB
    printf "  <1 GiB  : ";hashPut $lessTh1GiB
    printf "  >=1 GiB : ";hashPut $greaterEq1GiB
  }
fi

#-------------------Regex---------------------#

#files specified by regex are to be ignored
if [ $regexFlag -eq 1 ]; then
  # #"${DIR##*/}" #gets the name of the directory

  ls -lR "$DIR" | grep ^d | awk '{print substr($0, index($0,$9))}' | {
    while read -r line; do
      ignoreFolder "$line"
    done
    echo "Diretories: $ND"
  }

  # dirname soubor | xargs basename
  # alebo
  # basename $(dirname soubor)

  # ls -lR "$DIR" | grep ^d | grep -v "$regex" | wc -l | {
  #   read -r allFolders
  #   ND=$allFolders
  #   ND=$((ND+1))
  #   echo "Directories: $ND"
  # }
  # echo "<<REGEX:$regex<<"
  # Directs=$(find "$DIR" -type d | egrep -v "$regex" | wc -l)

  # NF=`find $DIR -type f | grep -v "$regex" | wc -l`
  # alldircount=$(find $DIR -type d \( -path '*/.*' -prune -o ! -name '.*' \) -a -name "$regex" | wc -l) 2>/dev/null
  #
  # allfilecount=$(find "$DIR" \( -path '*/.*' -prune -o ! -name '.*' \) -type f -a -name "$regex" | wc -l) 2>/dev/null
  #
  # list=$(find "$DIR" -type f \( -path '*/.*' -prune -o ! -name '.*' \) -a -name "$regex" | while read line; do cat "$line" | wc -c; done | sort -nr) 2>/dev/null
  #
  # for i in `seq 1 $allfilecount`; do
	# #krajime promennou list podle poctu souboru v ni ulozenych
	#  size=$(echo $list | cut -f"$i" -d' ')
  #  filter $size
  # done
  #
  # ls -lR "$DIR" | grep ^d | grep -v "$regex" | wc -l | {
  #   read -r allFolders
  #   ND=$allFolders
  #   ND=$((ND+1))
  #   echo "Directories: $ND"
  # }
  #
  # ls -lR -la "$DIR" | grep ^- | grep -v "$regex" | wc -l | {
  #   read -r allFiles
  #   NF=$allFiles
  #   echo "All files: $NF"
  # }
  #
  # echo ">>>>$regex>>>>"

  echo "File size histogram:"
  printf "  <100 B  : ";hashPut $lessTh100B
  printf "  <1 KiB  : ";hashPut $lessTh1KiB
  printf "  <10 KiB : ";hashPut $lessTh10KiB
  printf "  <100 KiB: ";hashPut $lessTh100KiB
  printf "  <1 MiB  : ";hashPut $lessTh1MiB
  printf "  <10 MiB : ";hashPut $lessTh10MiB
  printf "  <100 MiB: ";hashPut $lessTh100MiB
  printf "  <1 GiB  : ";hashPut $lessTh1GiB
  printf "  >=1 GiB : ";hashPut $greaterEq1GiB
fi

#---------------------------------------------#
#---------------Normalisation-----------------#

if [ "$normalisationFlag" -eq 1 ]; then
  findMaximum
  #if done within terminal window
  if [ -t 1 ]; then
    width=$(tput cols);
    width=$((width-13))
  else
    width="79-12"
  fi

  #if maximum exceeds the width of the window, values are adjusted
  if [ "$maximum" -gt "$width" ]; then
    normalise "$width" "$maximum"
  fi
fi

#---------------------------------------------#
#-------------Statistics display--------------#

# echo "File size histogram:"
# printf "  <100 B  : ";hashPut $lessTh100B
# printf "  <1 KiB  : ";hashPut $lessTh1KiB
# printf "  <10 KiB : ";hashPut $lessTh10KiB
# printf "  <100 KiB: ";hashPut $lessTh100KiB
# printf "  <1 MiB  : ";hashPut $lessTh1MiB
# printf "  <10 MiB : ";hashPut $lessTh10MiB
# printf "  <100 MiB: ";hashPut $lessTh100MiB
# printf "  <1 GiB  : ";hashPut $lessTh1GiB
# printf "  >=1 GiB : ";hashPut $greaterEq1GiB

#---------------------------------------------#
#---------------End of code-------------------#

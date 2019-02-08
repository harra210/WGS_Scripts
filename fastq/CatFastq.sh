#!/bin/bash
pwd=$(pwd)
cd ..
pwd_base=$(pwd)
cd $pwd
###### INTERACTIVE SECTION #######
echo "What directory are the fastq's needed to be concatenated located in?"
read -e -p "Fastq Directory: " FASTQ_DIR
echo "What do you want to name the concatenated file?"
read -e -p "Filename: " FN
echo "What Read (R1 or R2) are you wanting to concatenate?"
read -e -p "Read: " READ
##### END INTERACTIVE SECTION ######
NUMREAD=$(sed 's/R//' <<< "$READ")
cd $FASTQ_DIR
find . -maxdepth 1 -name "*_"$READ"_*" -printf '%f\n' &> $pwd_base/tmp/fastq/catfastq.tmp
#
cd $pwd_base/tmp/fastq/
IFS=,$'\n' read -d '' -r -a fastq < catfastq.tmp
sortedfastq=( $(printf "%s\n" ${fastq[*]} | sort -V ) )
declare -a sortedfastq
unset IFS
##Debug Section
#echo $NUMREAD
#echo ${sortedfastq[*]}
echo "cat ${sortedfastq[*]} > "$FN"_"$NUMREAD".fastq.gz"
echo "verify command input"
read -sp "`echo -e 'Press any key to continue or Ctrl+C to abort \n\b'`" -n1 key
echo "Working"
#sleep 20;
#
cd $FASTQ_DIR;
cat ${sortedfastq[*]} > "$FN"_"$NUMREAD".fastq.gz
echo "done"
#END

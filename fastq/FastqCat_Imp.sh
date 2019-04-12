#!/bin/bash
###### INTERACTIVE SECTION #######
echo "What parent directory are the fastq's needed to be concatenated located in? (Do not include sample folder)"
read -e -p "Fastq Directory: " FASTQ_DIR
echo "What sample do want to concatenate?"
read -e -p "Filename: " FN
echo "What Read (R1 or R2) are you wanting to concatenate?"
read -e -p "Read: " READ
##### END INTERACTIVE SECTION ######
NUMREAD=$(sed 's/R//' <<< "$READ")
cd "$FASTQ_DIR"/"$FN"/
find . -maxdepth 1 -name "*_"$READ"_*" -printf '%f\n' &> /data/Ostrander/scripts/tmp/fastq/fastqcat_imp.tmp
#
cd /data/Ostrander/scripts/tmp/fastq/
IFS=,$'\n' read -d '' -r -a fastq < fastqcat_imp.tmp
sortedfastq=( $(printf "%s\n" ${fastq[*]} | sort -V ) )
declare -a sortedfastq
unset IFS
cd "$FASTQ_DIR"/"$FN"/
##Debug Section
#pwd
#echo $NUMREAD
#echo ${sortedfastq[*]}
#sleep 30;
#
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

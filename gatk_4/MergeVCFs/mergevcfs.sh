#!/bin/bash
> swarm_mergevcfs.txt
###### INTERACTIVE SECTION ######
echo "What directory are the VCF's that need to be merged located in?"
read -e -p "VCF location: " VCF_DIR
echo "What do you want to call your combined vcf file?"
read -e -p "File name: " FILENAME
echo "What Chromosome are you merging? Use All if merging All"
read -e -p "Chromosome: " CHR
######
cd $VCF_DIR
find . -maxdepth 1 -name "*chr"$CHR".vcf.gz" -printf '%f\n' &> /data/Ostrander/scripts/tmp/gatk/mergevcfs.tmp
#
cd /data/Ostrander/scripts/tmp/gatk/
IFS=,$'\n' read -d '' -r -a vcf < mergevcfs.tmp
sortedvcf=( $(printf "%s\n" ${vcf[*]} | sort -V ) )
declare -a sortedvcf
unset IFS
PREFIX="I="
#echo ${sortedvcf[*]} ## For Debug
#sleep 30; ## for Debug
#
cd /data/Ostrander/scripts/gatk/gatk_4.0.8.1/GatherVcfs
echo "cd $VCF_DIR; java -Xmx64g -jar \$PICARDJARPATH/picard.jar MergeVcfs "${sortedvcf[*]/#/$PREFIX}" O="$FILENAME".chr"$CHR".vcf.gz" > swarm_gathervcfs.txt
#
#for i in "${sortedvcf[*]}"
#do
#echo "cd $VCF_DIR; java -Xmx8g -jar \$PICARDJARPATH/picard.jar GatherVcfs I=$i O="$FILENAME".chrAll.vcf.gz" >> swarm_gathervcfs.txt
#done
more swarm_gathervcfs.txt
read -sp "`echo -e 'Press any key to continue or Ctrl+C to abort \n\b'`" -n1 key
#
echo "Swarm JobID:"
#
swarm -f swarm_gathervcfs.txt -g 72 --time 120:00:00 --module picard --logdir ~/job_outputs/picard/gathervcfs --sbatch "--mail-type=ALL,TIME_LIMIT_80"

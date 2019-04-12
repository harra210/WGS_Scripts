#!/bin/bash
> swarm_vcfmerge.txt
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
#echo ${vcf[*]}
cd /data/Ostrander/scripts/troubleshooting_scripts
echo "cd $VCF_DIR; vcf-merge "${sortedvcf[*]/#/$PREFIX}" | bgzip -c > "$FILENAME".chr"$CHR".vcf.gz " > swarm_vcfmerge.txt
more swarm_vcfmerge.txt
read -sp "`echo -e 'Press any key to continue or Ctrl+C to abort \n\b'`" -n1 key
#
echo "Swarm JobID:"
#
swarm -f swarm_vcfmerge.txt -g 12 --time 240:00:00 --module vcftools --logdir ~/job_outputs/troubleshooting_scripts/vcfmerge --sbatch "--mail-type=ALL,TIME_LIMIT_80"

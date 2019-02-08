#!/bin/bash
pwd=$(pwd)
cd ../../..
pwd_base=$(pwd)
cd $pwd
> swarm_CatVariants.txt
###### INTERACTIVE SECTION ######
echo "What directory are the VCF's that need to be gathered located in?"
read -e -p "VCF location: " VCF_DIR
echo "What directory do you want to output your combined vcf file?"
read -e -p "Output directory: " OUT_DIR
echo "What do you want to call your combined vcf file?"
read -e -p "File name: " FILENAME
######
cd $VCF_DIR
find . -maxdepth 1 -name "*.vcf.gz" -printf '%f\n' &> $pwd_base/tmp/gatk/catvariants.tmp
#
cd $pwd_base/tmp/gatk/
IFS=,$'\n' read -d '' -r -a vcf < catvariants.tmp
sortedvcf=( $(printf "%s\n" ${vcf[*]} | sort -V ) )
declare -a sortedvcf
unset IFS
PREFIX="-V "
#echo ${sortedvcf[*]} ## For Debug
#sleep 30; ## for Debug
#
cd $pwd
echo "cd $VCF_DIR; java -Xmx64g -Djava.io.tmpdir/lscratch/\$SLURM_JOB_ID -cp \$GATK_JAR org.broadinstitute.gatk.tools.CatVariants -R /data/Ostrander/Resources/cf31PMc.fa "${sortedvcf[*]/#/$PREFIX}" -out "$OUT_DIR""$FILENAME".chrAll.vcf.gz -assumeSorted;" > swarm_CatVariants.txt
#for i in "${sortedvcf[*]}"
#do
#echo "cd $VCF_DIR; java -Xmx8g -jar \$PICARDJARPATH/picard.jar GatherVcfs I=$i O="$FILENAME".chrAll.vcf.gz" >> swarm_gathervcfs.txt
#done
more swarm_CatVariants.txt
read -sp "`echo -e 'Press any key to continue or Ctrl+C to abort \n\b'`" -n1 key
#
echo "Swarm JobID:"
#
swarm -f swarm_CatVariants.txt -g 72 --time 120:00:00 --module GATK --logdir ~/job_outputs/gatk/catvariants --sbatch "--mail-type=ALL,TIME_LIMIT_80"

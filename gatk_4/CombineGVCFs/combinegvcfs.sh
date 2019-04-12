#!/bin/bash
> swarm_combinegvcfs.txt
pwd=$(pwd)
cd ../../../
pwd_base=$(pwd)
> combinegvcfs.sh
###### INTERACTIVE SECTION ######
echo "Where are the g/VCFs that you wish to combine?"
read -e -p "gVCF location: " GVCF_DIR
echo "Where do you want to output the combined VCF?"
read -e -p "Output location: " OUT_DIR
echo "What do you want to call your combined VCF?"
read -e -p "VCF Name: " OUT_NAME
echo "What do you want to name your swarm?"
read -e -p "Swarm Name: " SWARM_NAME
###### END INTERACTIVE SECTION ######
#722 Master section
cd "$pwd_base"/tmp/gatk/gatk3/
IFS=,$'\n' read -d '' -r -a database < genotypegvcfs_722.tmp
#echo "${database[@]}" # for debug
#Experimental gVCFs section
#Search through the directories
cd $GVCF_DIR
#find $PWD -name "*_g.vcf.gz" -printf '%h\n' &> "$pwd_base"/tmp/gatk/combinegvcf_directories.tmp
find $PWD -name '*_g.vcf.gz' > $pwd_base/tmp/gatk/combinegvcf_names.tmp
cd $pwd_base/tmp/gatk/
#End finding section
IFS=,$'\n' read -d '' -r -a samplename < combinegvcf_names.tmp
echo "${database[@]}" > "$pwd_base"/tmp/gatk/full_list.tmp
echo "${samplename[@]}" >> "$pwd_base"/tmp/gatk/full_list.tmp
IFS=,$'\n' read -d '' -r -a fulllist < full_list.tmp
list=( $(printf "%s\n" ${fulllist[*]} ) )
declare -a list
unset IFS
#echo ${samplename[*]} # For debug
#read -sp "`echo -e 'Debugging mode! Press enter to continue or Ctrl+C to abort \n\b'`" -n1 key # For debug
PREFIX="--variant "
cd $pwd
#Create swarm commands for Chromosomes 1 through 38
for i in {1..38}
do
	echo "cd $GVCF_DIR; gatk --java-options \"-Xmx72g -XX:ParallelGCThreads=6\" CombineGVCFs -R /data/Ostrander/Resources/cf31PMc.fa "${list[*]/#/$PREFIX}" -D /data/Ostrander/Resources/CFA31_151.dbSNP_num_order.vcf.gz -L chr$i -O "$OUT_DIR""$OUT_NAME".chr"$i".vcf.gz --tmp-dir /lscratch/\$SLURM_JOB_ID" >> swarm_combinegvcfs.txt
done
#ChrX
echo "cd $GVCF_DIR; gatk --java-options \"-Xmx72g -XX:ParallelGCThreads=6\" CombineGVCFs -R /data/Ostrander/Resources/cf31PMc.fa "${list[*]/#/$PREFIX}" -D /data/Ostrander/Resources/CFA31_151.dbSNP_num_order.vcf.gz -L chrX -O "$OUT_DIR""$OUT_NAME".chrX.vcf.gz --tmp-dir /lscratch/\$SLURM_JOB_ID" >> swarm_combinegvcfs.txt
#
head -n 1 swarm_combinegvcfs.txt # This displays the first line of the swarm file. Edit the number of lines if you desire to see more. Due to the amount of variants, displaying only one line has been chosen.
read -sp "`echo -e 'Press any key to continue or Ctrl+C to abort \n\b'`" -n1 key
echo "Swarm JobID:"
#
swarm -f swarm_combinegvcfs.txt -g 80 -t 10 --time 240:00:00 --module GATK/4.1.0.0 --gres=lscratch:400 --logdir ~/job_outputs/gatk/combinegvcfs/ --sbatch "--mail-type=ALL,TIME_LIMIT_80 --job-name $SWARM_NAME --cpus-per-task=8"

#!/bin/bash
pwd=$(pwd)
cd ../../..
pwd_base=$(pwd)
cd $pwd
> gatk4_HCaller_script_swarmfile.swarm
###### INTERACTIVE SECTION ######
# Section asks for where fastq files are located that user wants to align
echo "What parent directory are your BQSR files that you want to have HaplotypeCaller run on?";
read -e -p "BQSR directory: " BQSR_DIR
echo "What do you want to name your swarm?"
read -e -p "Swarm name: " SWARM_NAME
# Script then prompts user to select a directory to place the VCF files, if you want to output your files all in one locaiton, as opposed to placing the files in their individual sample folders
#echo "What directory do you want to place the output VCF files?";
#read -e -p "Output directory: " OUT_DIR
#
# NON-INTERACTIVE SECTION 
# Line 8 directs script to change to directory given by user prompt and then search the directory for BQSR bams, trim the _BQSR.bam from the find results and then output that to a temporary file to for later use in the script
#
cd $BQSR_DIR
find $PWD -name "*_1.fastq.gz" -printf '%h\n' &> $pwd_base/tmp/gatk/BQSR_directory.txt
find . -name "*_BQSR4.bam" -printf '%f\n' | sed 's/_BQSR4.bam//' > $pwd_base/tmp/gatk/BQSR_samples.txt
#
cd $pwd_base/tmp/gatk
#
# This section will read the temp file created earlier and take the contents of the file and place them into an array.
IFS=,$'\n' read -d '' -r -a samplename < BQSR_samples.txt
IFS=,$'\n' read -d '' -r -a directories < BQSR_directory.txt
#
sample=( $(printf "%s\n" ${samplename[*]} | sort -n ) )
directory=( $(printf "%s\n" ${directories[*]} | sort -n ) )
declare -a sample
declare -a directory
unset IFS
#
cd $pwd
# After switching back to script directory, the script will then iterate across the array and create the contents of the swarmfile
for ((i = 0; i < ${#directory[@]}; i++))
do
	echo "cd ${directory[$i]}; gatk --java-options \"-Xmx12g\" HaplotypeCaller -R /data/Ostrander/Resources/cf31PMc.fa -I "${sample[$i]}"_BQSR4.bam -O "${sample[$i]}"_g.vcf.gz --bam-output "${sample[$i]}"_realigned.bam --output-mode EMIT_ALL_SITES -ERC GVCF --pcr-indel-model NONE --smith-waterman FASTEST_AVAILABLE --TMP_DIR /lscratch/\$SLURM_JOB_ID" >> gatk4_HCaller_script_swarmfile.swarm
done
# After creating the swarm file it will then display the contents of the swarmfile and then pause to allow the user to verify that the swarmfile is correct. If not the user can control+c to abort the script. If the user does not abort and continues it will then submit to the cluster
more gatk4_HCaller_script_swarmfile.swarm
read -sp "`echo -e 'Press any key to continue or Ctrl+C to abort \n\b'`" -n1 key
#
echo "Swarm JobID:"
#
swarm -f gatk4_HCaller_script_swarmfile.swarm -g 14 -t 4 --time 120:00:00 --module GATK/4.0.12.0 --gres=lscratch:300 --logdir ~/job_outputs/gatk/haplotypecaller --sbatch "--mail-type=ALL,TIME_LIMIT_80 --job-name $SWARM_NAME"
# The script will create a folder to place swarm files in the submitting users home directory.

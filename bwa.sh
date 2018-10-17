#!/bin/bash
#
#IMPORTANT: MAKE SURE THAT YOUR FASTQ FILES ARE IDENTICALLY NAMED TO YOUR SUB-DIRECTORY NAMES. IF THIS IS NOT THE CASE, THIS SCRIPT WILL FAIL!#
#The ideal file structure for this project is ~/project_name/Fastq_files_folder/ where fastq's are in their own folders.
#
cd /data/harrisac2/SRAdb/fastq_dump/African_Dogs #This finds your parent directory containing your subdirectories which contain your fastq's
#
#
######Variable definitions####
#
array=($(ls -d */ | sed '/\./d;s%/$%%'))
#
#####Line 7 creates an array out of the subdirectories which is the basis of automating the remainder of the script, this is why having your subdirectory names be IDENTICAL to your file names (sans extensions)#####
#
######For verification purposes. If having issues with the script, remove the hashtag so you can see what names the script is calling######
#echo ${array[@]}
#############
cd /data/Ostrander/Alex/scripts #This line will change the directory from where your fastq's are located to where you will generate your swarm files.
for srr in "${array[@]}"
#
######This section generates your swarm file. Make sure for line 17, that looking for your split fastq files that they are labeled correctly, either fastq or gunzip'd foo.fastq.gz. This will cause failures when performing the swarm function 
#
do
	echo "cd /data/harrisac2/SRAdb/fastq_dump/African_Dogs/$srr; bwa mem -M -t \$SLURM_CPUS_PER_TASK /data/Ostrander/Resources/cf31PMc.fa "$srr"_1.fastq "$srr"_2.fastq > /scratch/harrisac2/"$srr"_temp.sam;" >> Script_WGS_BWAmem_Swarm.txt
done
echo "Swarmfile created"
sleep 1;
#Your swarm file is now created and it will now copy a version and labeled as lastrun.
cp Script_WGS_BWAmem_Swarm.txt script_bwamem_lastrun.txt
sleep 1;
swarm -f Script_WGS_BWAmem_Swarm.txt -g 32 -t 20 --time 96:00:00 --module bwa --logdir ~/job_outputs/SRAdb/bwa_mem --sbatch "--mail-type=START,END,FAIL"
#Line 24 runs the swarm file you generated to the cluster, and has options set up to email you via the e-mail account tied to your Biowulf account when the swarm begins, ends and if it fails.
#NOTE: In the swarm code line (Line 24) change the logdir to your own specified location to place your STDIN and STDERR files. 
rm Script_WGS_BWAmem_Swarm.txt
echo "BWA-MEM section submitted"
#This final section removes the original swarmfile so that you can simply rerun the script with minimal user input. If you so desire, you can blank your copied file in the command line running the command $ > script_bwamem_lastrun.txt

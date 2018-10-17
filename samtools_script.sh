#!/bin/bash
###This script will prepare and execute the swarm for the samtools portion of the aligning pipeline. This is step 2.
cd /data/harrisac2/SRAdb/fastq_dump/African_Dogs # This line sets your working directory. Your subfolders need to be in this directory.
#
#How this script will work is that it takes your split read files that should be in their own individual folders sorted by run. It will then base the name off of that subdirectory.
###### IMPORTANT! MAKE SURE YOUR FILES ARE NAMED THE SAME AS THE PARENT DIRECTORY. FOR EXAMPLE IF YOUR SAMPLE IS Foo.fastq.gz THEN YOUR DIRECTORY SHOULD BE NAMED Foo. IF THEY ARE NOT NAMED THE SAME THIS SCRIPT WILL FAIL TO RUN ON THE CLUSTER. ######
#
######Variable Definitions######
#
array=($(ls -d */ | sed '/\./d;s%/$%%'))
#
######
cd ~/scripts/samtools
for srr in "${array[@]}"
do
	echo "cd /data/harrisac2/SRAdb/fastq_dump/African_Dogs/$srr; samtools view -o "$srr"_temp.bam -Shbu /scratch/harrisac2/"$srr"_temp.sam ; samtools sort -o sort_"$srr".bam -T /lscratch/\$SLURM_JOB_ID/ "$srr"_temp.bam; samtools index sort_"$srr".bam" >> samtools_script_swarmfile.swarm
done
echo "Samtools swarmfile created";
cp samtools_script_swarmfile.swarm samtools_script_lastrun.txt
sleep 1;
#
swarm -f samtools_script_swarmfile.swarm -g 16 --gres=lscratch:200 --time 96:00:00 --module samtools --logdir ~/job_outputs/SRAdb/samtools --sbatch "--mail-type=BEGIN,END,FAIL"
#> samtools_script_swarmfile.txt && echo "samtools_script_swarmfile.txt blanked ready for reuse" || echo "samtools_script_swarmfile.txt unable to be blanked"
rm samtools_script_swarmfile.swarm
echo "Samtools section submitted"

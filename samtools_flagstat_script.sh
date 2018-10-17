#!/bin/bash
cd /data/harrisac2/SRAdb/fastq_dump/African_Dogs
#
######Variable definitions######
#
array=($(ls -d */ | sed '/\./d;s%/$%%'))
cd ~/scripts/samtools
for srr in "${array[@]}"
do
	echo "cd /data/harrisac2/SRAdb/fastq_dump/African_Dogs/$srr; samtools flagstat "$srr"_temp.bam > /data/Ostrander/Alex/flagstat_outputs/"$srr"_flagstat.o" >> samtools_flagstat_script.txt
done
echo "Swarmfile created";
sleep 1;
cp samtools_flagstat_script.txt samtools_flagstat_lastrun.txt
sleep 1;
#
swarm -f samtools_flagstat_script.txt -g 4 --time 3:00:00 --module samtools --logdir ~/job_outputs/SRAdb/samtools/flagstat --sbatch "--mail-type=START,END,FAIL"
#
rm samtools_flagstat_script.txt
echo "Flagstat submitted"

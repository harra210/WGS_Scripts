#!/bin/bash
cd /data/Ostrander/scripts/gatk
> gatk3_BRPR_swarmfile.txt
###### INTERACTIVE SECTION ######
#Section asks for where fastq files are located that user wants to align
echo "What directory are your dedup files that you want to have BQSR'd?";
read -e -p "dedup directory: " DD_DIR
cd $DD_DIR
###### NON-INTERACTIVE SECTION ######
#Next line will perform a find command in the FQ_DIR, looking for one set of the paired end reads only so it can print out the sample names. It will output the results of the find | sed command to a temp file
#
cd /data/Ostrander/scripts/tmp/gatk/
#
#This section will read the temp file created earlier and take the contents of the file and place them into an array.
IFS=,$'\n' read -d '' -r -a samplename < BQSR_final.txt
#
cd /data/Ostrander/scripts/gatk
#After switching back to script directory, the script will then iterate across the array and create the contents of the swarmfile
for srr in "${samplename[@]}"
do
	echo "cd $DD_DIR; java -Xmx16g -Djava.io.tmpdir=/lscratch/\$SLURM_JOBID -XX:ParallelGCThreads=4 -jar \$GATK_JAR -T PrintReads -R /data/Ostrander/Resources/cf31PMc.fa -I dedup_"$srr".bam --BQSR /data/Ostrander/Alex/WGS_bams/"$srr"_recal.table -o /data/Ostrander/Alex/WGS_bams/"$srr"_BQSR.bam" >> gatk3_BR_swarmfile.txt
done
echo "GATK 3.8.0 BaseRecalibrator and PrintReads swarmfile created";
sleep 1;
#
#Following section submits swarmfile to the cluster
swarm -f gatk3_BR_swarmfile.txt -g 18 -t 6 --gres=lscratch:200 --time 120:00:00 --module GATK --logdir ~/job_outputs/gatk --sbatch "--mail-type=BEGIN,END,FAIL"
echo "GATK 3.8.0 BaseRecalibrator and PrintReads submitted"

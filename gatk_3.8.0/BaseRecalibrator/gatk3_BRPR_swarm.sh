#!/bin/bash
pwd=$(pwd)
cd ../../..
pwd_base=$(pwd)
cd $pwd
> gatk3_BRPR_swarmfile.txt
###### INTERACTIVE SECTION ######
#Section asks for where fastq files are located that user wants to align
echo "What directory are your dedup files that you want to have BQSR'd?";
read -e -p "dedup directory: " DD_DIR
echo "What directory do you want to place the output files of this script to?";
read -e -p "output directory: " OUT_DIR
cd $DD_DIR
###### NON-INTERACTIVE SECTION ######
#Next line will perform a find command in the FQ_DIR, looking for one set of the paired end reads only so it can print out the sample names. It will output the results of the find | sed command to a temp file
#
cd $pwd_base/tmp/gatk/
#
#This section will read the temp file created earlier and take the contents of the file and place them into an array.
IFS=,$'\n' read -d '' -r -a samplename < BQSR_final.txt
#
cd $pwd
#After switching back to script directory, the script will then iterate across the array and create the contents of the swarmfile
for srr in "${samplename[@]}"
do
	echo "cd $DD_DIR; java -Xmx16g -Djava.io.tmpdir=/lscratch/\$SLURM_JOBID -XX:ParallelGCThreads=4 -jar \$GATK_JAR -T PrintReads -R /data/Ostrander/Resources/cf31PMc.fa -I dedup_"$srr".bam --BQSR "$OUT_DIR""$srr"_recal.table -o "$OUT_DIR""$srr"_BQSR.bam" >> gatk3_BRPR_swarmfile.txt
done
more gatk3_BRPR_swarmfile.txt
read -sp "`echo -e 'Press any key to continue or Ctrl+C to abort \n\b'`" -n1 key
#
#Following section submits swarmfile to the cluster
echo "Swarm JobID: "
swarm -f gatk3_BR_swarmfile.txt -g 18 -t 6 --gres=lscratch:200 --time 120:00:00 --module GATK --logdir ~/job_outputs/gatk --sbatch "--mail-type=ALL,TIME_LIMIT_90"

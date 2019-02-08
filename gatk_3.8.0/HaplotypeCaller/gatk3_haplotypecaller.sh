#!/bin/bash
pwd=$(pwd)
cd ../../..
pwd_base=$(pwd)
cd $pwd
> gatk3_HCaller_script_swarmfile.swarm
###### INTERACTIVE SECTION ######
#Section asks for where fastq files are located that user wants to align
echo "What directory are your BQSR files that you want to have HaplotypeCaller run on?";
read -e -p "BQSR directory: " BQSR_DIR
cd $BQSR_DIR
# Script then asks 
#echo "What directory are you running your samples on run on?";
#read -e -p "Sample directory: " SAMPLE_DIR
#
# Script then asks what directory the user wants to put the output in. Note directory must exist prior to running script
echo "What directory do you want to place the output files of this script to?";
read -e -p "Output directory: " OUT_DIR
#
# NON-INTERACTIVE SECTION 
#
find . -name "*_BQSR.bam" -printf '%f\n' | sed 's/_BQSR.bam//' > $pwd_base/tmp/gatk/BQSR_samples.txt
#
cd $pwd_base/tmp/gatk
#
#This section will read the temp file created earlier and take the contents of the file and place them into an array.
IFS=,$'\n' read -d '' -r -a samplename < BQSR_samples.txt
#
cd $pwd
#After switching back to script directory, the script will then iterate across the array and create the contents of the swarmfile
for srr in "${samplename[@]}"
do
	echo "cd $BQSR_DIR; java -Xmx8g -Djava.io.tmpdir=/lscratch/\$SLURM_JOBID -XX:ParallelGCThreads=4 -jar \$GATK_JAR -T HaplotypeCaller -R /data/Ostrander/Resources/cf31PMc.fa -I "$srr"_BQSR.bam -o "$OUT_DIR""$srr".g.vcf.gz --output_mode EMIT_ALL_SITES -ERC GVCF --pcr_indel_model NONE -variant_index_type LINEAR -variant_index_parameter 128000" >> gatk3_HCaller_script_swarmfile.swarm
done
#Script then displays the swarmfile and the requests user input by either a single key to continue the script if the swarmfile is correct or if the user needs to change something they can Ctrl+C to abort the script without submitting to the cluster
more gatk3_HCaller_script_swarmfile.swarm
read -sp "`echo -e 'Press any key to continue or Ctrl+C to abort \n\b\'`" -n1 key
echo "Swarm JobID: "
#
swarm -f gatk3_HCaller_script_swarmfile.swarm -g 10 -t 10 --time 240:00:00 --module GATK --logdir ~/job_outputs/gatk --sbatch "--mail-type=ALL"

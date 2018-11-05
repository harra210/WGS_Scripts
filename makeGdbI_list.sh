#!/bin/bash
#first blank the masterlist before recreating it
cd /data/harrisac2/GVCF_lists/script/temp/
> names.txt
> originalnames.txt
> gvcf_masterlist.txt
echo "gvcf_masterlist.txt blanked"
cp vcf_grep_list.txt gvcf_masterlist.txt
echo "gvcf_masterlist.txt repopulated with original list"
> names_positive.txt
echo "names_positive.txt blanked"
#Change directory to that containing the newly created WGS samples to print the sample name
cd /data/harrisac2/GVCF_lists/New_GVCF_files
find . -name '*_g.vcf.gz' -printf '%f\n' | sed 's/_g.vcf.gz//' &> /data/harrisac2/GVCF_lists/script/temp/names.txt
find . -name '*_g.vcf.gz' -printf '%f\n' | sed 's/_g.vcf.gz//' &> /data/harrisac2/GVCF_lists/script/temp/originalnames.txt
#Append your samples to the master list so that when you compare files and then select what you need your samples are not deleted when you grep
find . -name '*_g.vcf.gz' -printf '%f\n' | sed 's/_g.vcf.gz//' &>> /data/harrisac2/GVCF_lists/script/temp/gvcf_masterlist.txt
echo "Database names fully loaded into gvcf_masterlist.txt"
#Change directory containing previously created VCFs
cd /data/harrisac2/VCF_database/
find . -name '*.gz' ! -name '*.gz.tbi' -printf '%f\n' | sed 's/.g.vcf.gz//' &>> /data/harrisac2/GVCF_lists/script/temp/names.txt
#Compares both the name file you just created to the masterlist and then outputs positive matches to a new file
cd /data/harrisac2/GVCF_lists/script/temp
grep -Fwf names.txt gvcf_masterlist.txt > names_positive.txt
echo "names_positive.txt created"
#
#Following section details manipulating the files you just created to finalize them into the proper syntax for GenomicsDBImport
#
IFS=,$'\n' read -d '' -r -a database < vcf_grep_list.txt
for db in "${database[@]}"
do
	echo "/data/harrisac2/VCF_database/"$db".g.vcf.gz" &> /data/harrisac2/GVCF_lists/script/temp/final_newgvcffiles.txt
done
#
IFS=,$'\n' read -d '' -r -a samplename < originalnames.txt
for srr in "${samplename[@]}"
do
        echo "/data/harrisac2/GVCF_lists/New_GVCF_files/"$srr"_g.vcf.gz" &>> /data/harrisac2/GVCF_lists/script/temp/final_newgvcffiles.txt
done
#
paste names_positive.txt final_newgvcffiles.txt > /data/harrisac2/GVCF_lists/GenomicsDB_samplemap.txt
echo "GenomicsDBImport Sample Map created"
#
#Following section generates the swarmfile to submit to the cluster
#
cd /data/harrisac2/GVCF_lists
for i in  {1..38}
do
echo "cd /data/harrisac2/GVCF_lists/; gatk --java-options \"-Xmx8g -Xms8g -XX:ParallelGCThreads=4 -DGATK_STACKTRACE_ON_USER_EXCEPTION=true\" GenomicsDBImport --genomicsdb-workspace-path db/chr$i -L chr$i --sample-name-map GenomicsDB_samplemap.txt --TMP_DIR=/lscratch/\$SLURM_JOB_ID" >> GenomicsDBImport_swarmfile.swarm
done
#
#Following section actually submits the swarmfile to the cluster
#
#swarm -f Import_swarmfile.swarm -g 6 -t 6 --gres=lscratch:200 --module GATK/4.0.8.1 --time 48:00:00 --logdir ~/job_outputs/090518/gatk/GenomicsDBImport --sbatch "--mail-type=BEGIN,END,FAIL"

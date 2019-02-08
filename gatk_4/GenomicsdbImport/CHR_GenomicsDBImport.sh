#!/bin/bash
#
# This script works using two different sets of g/VCF's to create a database: The Experimental VCFs and the Reference VCF's. Your experimental VCFs are the VCFs that are working their way through the pipeline and the reference VCFs are the VCF's from the 722+. Be sure of what files you are editing, for example do not put experimental VCF's in the list of reference VCF's. Doing so will cause the program to error out and fail to start.
#
#
#first blank the masterlist before recreating it
pwd=$(pwd)
cd $pwd/temp
> names.txt
> originalnames.txt
> gvcf_masterlist.txt
> final_newgvcffiles.txt
> directories.txt
echo "gvcf_masterlist.txt blanked"
#echo $PWD #DEBUG LINE
#read -sp"`echo -e 'Debug mode! Ctrl+C to kill script here. \n\b'`" -n1 key #DEBUG LINE
#cp vcf_grep_list.txt gvcf_masterlist.txt # ORIGINAL LINE FOR REFERENCE.
cp vcf_grep_list.txt gvcf_masterlist.txt # Edit the first text file with the name of your custom text file. Note: this is for reference vcfs only!
echo "gvcf_masterlist.txt repopulated with original list"
> names_positive.txt
echo "names_positive.txt blanked"
###### INTERACTIVE SECTION ######
echo "What directory are the gVCF's that you want to place into the GenomicsDB?"
read -e -p "Sample gVCF directory: " GVCF_DIR
sleep 1;
echo "Where do you want to place your Genomics Database?"
read -e -p "Database parent directory: " DB_DIR
echo "What do you want to call the swarm?"
read -e -p "Swarm name: " SWARM_NAME
#mkdir -p $DB_DIR/db
#Change directory to that containing the newly created WGS samples to print the sample name
cd $GVCF_DIR
find . -name '*_g.vcf.gz' -printf '%f\n' | sed 's/_g.vcf.gz//' | sort -n &> $pwd/temp/names.txt
find $PWD -name "*_1.fastq.gz" -printf '%h\n' &> $pwd/temp/directories.txt
find . -name '*_g.vcf.gz' -printf '%f\n' | sed 's/_g.vcf.gz//' | sort -n &> $pwd/temp/originalnames.txt
#Append your samples to the master list so that when you compare files and then select what you need your samples are not deleted when you grep
find . -name '*_g.vcf.gz' -printf '%f\n' | sed 's/_g.vcf.gz//' | sort -n &>> $pwd/temp/gvcf_masterlist.txt
echo "Database names fully loaded into gvcf_masterlist.txt"
#Change directory containing master database VCFs
cd /data/Ostrander/VCF_HapCall
find . -name '*.gz' ! -name '*.gz.tbi' -printf '%f\n' | sed 's/.g.vcf.gz//' &>> $pwd/temp/names.txt
#Compares both the name file you just created to the masterlist and then outputs positive matches to a new file
cd $pwd/temp
grep -Fwf names.txt gvcf_masterlist.txt > names_positive.txt
echo "names_positive.txt created"
#IFS=,$'\n' read -d '' -r -a namespos < names_positive.txt #for debug
#echo "${namespos[@]}" #for debug
#
#Following section details manipulating the files you just created to finalize them into the proper syntax for GenomicsDBImport
#
> database_final.txt
> new_gvcfs_final.txt
#IFS=,$'\n' read -d '' -r -a database < vcf_grep_list.txt #ORIGINAL LINE FOR REFERENCE
IFS=,$'\n' read -d '' -r -a database < vcf_grep_list.txt #Change text file if you have a custom reference vcf list. Make sure two custom reference vcf lines match!
#echo "${database[@]}" # for debug
IFS=,$'\n' read -d '' -r -a samplename < originalnames.txt
#echo "${samplename[@]}" # for debug
#read -sp"`echo -e 'Debugging mode! Press Ctrl+C to kill script at this point \n\b'`" -n1 key
IFS=,$'\n' read -d '' -r -a directories < directories.txt
#
sample=( $(printf "%s\n" ${samplename[*]} | sort -n ) )
directory=( $(printf "%s\n" ${directories[*]} | sort -n ) )
declare -a sample
declare -a directory
unset IFS
#
for db in "${database[@]}"
do
	echo "/data/Ostrander/VCF_HapCall/"$db".g.vcf.gz" >> database_final.txt
done
#The "specialized" for loop for when the gVCF's are all located in one centralized location. Comment out the for loop that you don't use.
#SPECIALIZED
#for srr in "${samplename[@]}"
#do
#	echo ""$GVCF_DIR""$srr"_g.vcf.gz" >> new_gvcfs_final.txt
#done
#
#The original for loop is for when your gVCF's are located in their own individual folders
#ORIGINAL
for ((i = 0; i < ${#directory[@]}; i++))
do
	echo ""${directory[$i]}"/"${sample[$i]}"_g.vcf.gz" >> new_gvcfs_final.txt
done
cat database_final.txt new_gvcfs_final.txt > final_fileloc.txt
paste names_positive.txt final_fileloc.txt > $pwd/GenomicsDB_samplemap.txt
echo "GenomicsDBImport Sample Map created"
#
#Following section generates the swarmfile to submit to the cluster
#
cd $pwd
more GenomicsDB_samplemap.txt
read -sp "`echo -e 'Verify samplemap! Press enter to continue or Ctrl+C to abort \n\b'`" -n1 key
> GenomicsDBImport_swarmfile.swarm
for i in  {1..38}
do
echo "cd $PWD; gatk --java-options \"-Xmx32g -Xms32g -DGATK_STACKTRACE_ON_USER_EXCEPTION=true\" GenomicsDBImport --genomicsdb-workspace-path "$DB_DIR"$i --batch-size 25 -L chr$i --sample-name-map GenomicsDB_samplemap.txt --tmp-dir=/lscratch/\$SLURM_JOB_ID -R /data/Ostrander/Resources/cf31PMc.fa" >> GenomicsDBImport_swarmfile.swarm
done
echo "cd $PWD; gatk --java-options \"-Xmx32g -Xms32g -DGATK_STACKTRACE_ON_USER_EXCEPTION=true\" GenomicsDBImport --genomicsdb-workspace-path "$DB_DIR"chrX --batch-size 25 -L chrX --sample-name-map GenomicsDB_samplemap.txt --tmp-dir=/lscratch/\$SLURM_JOB_ID -R /data/Ostrander/Resources/cf31PMc.fa" >> GenomicsDBImport_swarmfile.swarm
#
more GenomicsDBImport_swarmfile.swarm
read -sp "`echo -e 'Press any key to continue or Ctrl+C to abort \n\b'`"
echo "Swarm JobID: "
##Following section actually submits the swarmfile to the cluster
#
swarm -f GenomicsDBImport_swarmfile.swarm -g 64 -t 10 --gres=lscratch:200 --module GATK/4.0.12.0 --time 240:00:00 --logdir ~/job_outputs/gatk/GenomicsDBImport --sbatch "--mail-type=ALL --job-name $SWARM_NAME"


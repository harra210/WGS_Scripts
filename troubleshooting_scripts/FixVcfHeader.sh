#!/bin/bash
cd /data/Ostrander/scripts/troubleshooting_scripts
> fixvcfheaders_swarm.txt
###### INTERACTIVE SECTION ######
# Section asks user where vcfs that require fixing #
echo "What directory are the VCF files you wish to have their headers fixed?"
read -e -p "vcf directory: " vcf_dir
echo "What directory do you want to output your fixed VCF header files?"
read -e -p "output_directory: " out_dir
echo "What Chromosome are you merging? Use All if merging All"
read -e -p "Chromosome: " chr
### FOR INDIVIDUAL FILE ###
# Used for debug or un comment to use script for just singular file
#echo "What file do you want to fix the header?"
#read -e -p "file: " file
#echo "Where do you want to output the fixed vcf header file?"
#read -e -p "file_out: " file_out
## INDIVIDUAL NON-INTERACTIVE SECTION ##
#echo "cd $vcf_dir; java -Xmx4g -jar \$PICARDJARPATH/picard.jar FixVcfHeader I=$file O=$file_out TMP_DIR=/lscratch/\$SLURM_JOBID" >> fixvcfheaders_swarm.txt
## END INDIVIDUAL NON-INTERACTIVE SECTION ##
#
## BATCH NON-INTERACTIVE SECTION ##
cd $vcf_dir
find . -maxdepth 1 -name "*.chr"$chr".vcf.gz" ! -iname "*.chr"$chr".vcf.gz.tbi" -printf '%f\n' | sed 's/.vcf.gz//' > /data/Ostrander/scripts/tmp/gatk/fixvcfheaders.tmp
#
cd /data/Ostrander/scripts/tmp/gatk
#
#
IFS=,$'\n' read -d '' -r -a samplename < fixvcfheaders.tmp
#
cd /data/Ostrander/scripts/troubleshooting_scripts
#
for srr in "${samplename[@]}"
do
	echo "cd $vcf_dir; java -Xmx4g -jar \$PICARDJARPATH/picard.jar FixVcfHeader I="$srr".vcf.gz O="$srr".Headerfixed.vcf.gz H=/data/Ostrander/Experimental_VCFs/243g_JointCall.SNP.INDEL.chrAll.vcf.gz" >> fixvcfheaders_swarm.txt
done
more fixvcfheaders_swarm.txt
read -sp "`echo -e 'Press any key to continue or Ctrl+C to abort \n\b'`" -n1 key
#
#
echo "Swarm JobID #: "
swarm -f fixvcfheaders_swarm.txt -g 6 -t 4 --time 48:00:00 --module picard --logdir ~/job_outputs/picard/ --sbatch "--mail-type=ALL,TIME_LIMIT_90"

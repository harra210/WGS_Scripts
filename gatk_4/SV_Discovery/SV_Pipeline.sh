#!/bin/bash
> PipelineSV_swarmfile.swarm
pwd=$(pwd)
cd ../../../
pwd_base=$(pwd)
cd /data/Ostrander/Resources/SV_Resource_Files
Resource_Loc=$(pwd)
cd $pwd
###### INTERACTIVE SECTION ######
echo "What directory are the BAM's you want to do SV discovery on in?"
read -e -p "BAM directory: " BAM_DIR
echo "Where do you want to output your aligned contig SAM file?"
read -e -p "SAM Output Directory: " SAM_OUT
echo "Where do you want to output the VCF containing variants?"
read -e -p "SV VCF Output: " VCF_OUT
echo "What do you want to name your swarm?"
read -e -p "Swarm name: " SWARM_NAME
######
###### NON-INTERACTIVE SECTION ######
cd $BAM_DIR
##FOR TESTING ONLY##
find . -name '*_BQSR4.bam' -printf '%f\n' | sed 's/_BQSR4.bam//' | head -n 1 &> $pwd_base/tmp/gatk/SV_filenames.tmp
#find . -name '*.bam' -printf '%f\n' | sed 's/.bam//' | sort -V &> $pwd_base/tmp/gatk/SV_filenames.tmp
#
cd $pwd_base/tmp/gatk/
IFS=,$'\n' read -d '' -r -a bamnames < SV_filenames.tmp
unset IFS
#
cd $pwd
for i in "${bamnames[@]}"
do
	echo "cd $BAM_DIR; gatk StructuralVariationDiscoveryPipelineSpark -I "$i"_BQSR4.bam -R $Resource_Loc/cf31PMc.2bit --aligner-index-image $Resource_Loc/cf31PMc.fa.img --kmers-to-ignore $Resource_Loc/cf31PMc_Kmers_to_ignore.txt --contig-sam-file $SAM_OUT"$i"_aligned.sam -O "$VCF_OUT""$i"_SV.vcf --tmp-dir /lscratch/\$SLURM_JOB_ID" >> PipelineSV_swarmfile.swarm
done
more PipelineSV_swarmfile.swarm
read -sp "`echo -e 'Verify swarmfile! Press Enter to continue or Ctrl+C to abort \n\b'`" -n1 key
echo "Swarm JobID:"
#
swarm -f PipelineSV_swarmfile.swarm -g 36 -t 8 --module GATK/4.1.0.0 --gres=lscratch:200 --time 120:00:00 --logdir ~/job_outputs/gatk/SV_Discovery/"$SWARM_NAME" --sbatch "--mail-type=ALL --job-name $SWARM_NAME"
#

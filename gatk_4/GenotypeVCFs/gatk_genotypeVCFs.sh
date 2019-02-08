#!/bin/bash
pwd=$(pwd)
cd $pwd
> genotypeVCFs_swarm.txt
###### INTERACTIVE SECTION ######
echo "What path contains the GenomicsDB Workspace (db directory)?"
read -e -p "GenomicsDB Workspace: " DB_DIR
echo "Where do you want to output the combined GVCF?"
read -e -p "Joint gVCF Output: " OUT_DIR
echo "What name do you wish to call the joint called gVCF?"
read -e -p "Joint GVCF name: " NAME
echo "What do you want to name your swarm?"
read -e -p "Swarm name: " SWARM_NAME
###### END SECTION ######
#mkdir -p -- "$OUT_DIR"
###### NON-INTERACTIVE SECTION ######
for i in {1..38}
	do
		echo "cd $OUT_DIR; gatk --java-options \"-Xmx8g\" GenotypeGVCFs -R /data/Ostrander/Resources/cf31PMc.fa --include-non-variant-sites -V gendb://"$DB_DIR""$i" -O $OUT_DIR"$NAME".chr"$i".vcf.gz --tmp-dir=/lscratch/\$SLURM_JOB_ID" >> genotypeVCFs_swarm.txt
done
echo "cd $OUT_DIR; gatk --java-options \"-Xmx8g\" GenotypeGVCFs -R /data/Ostrander/Resources/cf31PMc.fa --include-non-variant-sites -V gendb://"$DB_DIR"chrX -O $OUT_DIR"$NAME".chrX.vcf.gz --tmp-dir=/lscratch/\$SLURM_JOB_ID" >> genotypeVCFs_swarm.txt
more genotypeVCFs_swarm.txt
read -sp "`echo -e 'Press any key to continue or Ctrl+C to abort \n\b'`" -n1 key
echo "Swarm JobID:"
######
swarm -f genotypeVCFs_swarm.txt -g 16 -t 8 --time 120:00:00 --module GATK/4.0.12.0 --gres=lscratch:400 --logdir ~/job_outputs/gatk/genotypevcfs --sbatch "--mail-type=ALL,TIME_LIMIT_80 --job-name $SWARM_NAME"

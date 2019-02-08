#!/bin/bash
cd /data/Ostrander/scripts/gatk/gatk_4.0.8.1/GenotypeVCFs/
> genotypeVCFs_swarm.txt
###### INTERACTIVE SECTION ######
echo "What is the full path to the VCF you want to genotype?"
read -e -p "VCF Location: " VCF_DIR
echo "Where do you want to output the combined GVCF?"
read -e -p "Joint gVCF Output: " OUT_DIR
echo "What name do you wish to call the joint called gVCF?"
read -e -p "Joint GVCF name: " NAME
###### END SECTION ######
#mkdir -p -- "$OUT_DIR"
###### NON-INTERACTIVE SECTION ######
#for i in {1..38}
#	do
#		echo "cd $OUT_DIR; gatk --java-options \"-Xmx8g\" GenotypeGVCFs -R /data/Ostrander/Resources/cf31PMc.fa -all-sites -V gendb://"$DB_DIR""$i" -O $OUT_DIR"$NAME".chr"$i".vcf.gz --tmp-dir=/lscratch/\$SLURM_JOB_ID" >> genotypeVCFs_swarm.txt
#done
echo "cd $PWD; gatk --java-options \"-Xmx8g\" GenotypeGVCFs -R /data/Ostrander/Resources/cf31PMc.fa -all-sites -V $VCF_DIR -O $OUT_DIR"$NAME".vcf.gz --tmp-dir=/lscratch/\$SLURM_JOB_ID" -L /data/Ostrander/Heidi/Merge2_722-243.SNP.INDEL.vcf.gz --add-output-vcf-command-line >> genotypeVCFs_swarm.txt
more genotypeVCFs_swarm.txt
read -sp "`echo -e 'Press any key to continue or Ctrl+C to abort \n\b'`" -n1 key
echo "Swarm JobID:"
######
swarm -f genotypeVCFs_swarm.txt -g 16 -t 8 --time 120:00:00 --module GATK/4.0.12.0 --gres=lscratch:400 --logdir ~/job_outputs/gatk/genotypevcfs --sbatch "--mail-type=ALL,TIME_LIMIT_80"

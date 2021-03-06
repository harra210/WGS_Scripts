#!/bin/bash
> swarm_SNP_VarRecal.txt
###### INTERACTIVE SECTION ######
echo "What directory is the vcf file to be recalibrated in?"
read -e -p "Sample file directory: " VCF_DIR
######
cd $VCF_DIR
find . -name '*.chrAll.vcf.gz' -printf '%f\n' | sed 's/.chrAll.vcf.gz//' &> /data/Ostrander/scripts/tmp/gatk/vqsr.tmp
cd /data/Ostrander/scripts/tmp/gatk/
IFS=,$'\n' read -d '' -r -a samplename < vqsr.tmp
#
cd /data/Ostrander/scripts/gatk/gatk_3.8.0/VariantRecalibrator
for i in "${samplename[@]}"
do
	echo "cd $VCF_DIR; java -Djava.io.tmpdir=/lscratch/\$SLURM_JOB_ID -Xmx64g -XX:ParallelGCThreads=\$SLURM_CPUS_PER_TASK -jar \$GATK_JAR -T ApplyRecalibration -R /data/Ostrander/Resources/cf31PMc.fa -input "$i".chrAll.vcf.gz --ts_filter_level 99.0 -tranchesFile "$i".SNP_recal.output.tranches -recalFile "$i".SNP_recal.output.recal -mode SNP -o "$i".SNP.chrAll.vcf.gz" > swarm_SNP_VarRecal.txt
done
more swarm_SNP_VarRecal.txt
read -sp "`echo -e 'Press any key to continue or Ctrl+C to abort \n\b'`"
echo "Swarm JobID:"
swarm -f swarm_SNP_VarRecal.txt -g 72 -t 26 --module GATK --time 96:00:00 --gres=lscratch:200 --logdir ~/job_outputs/gatk/VariantRecalibrator --sbatch "--mail-type=ALL,TIME_LIMIT_80"

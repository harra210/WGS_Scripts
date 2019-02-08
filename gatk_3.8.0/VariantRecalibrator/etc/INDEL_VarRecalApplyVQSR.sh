#!/bin/bash
> swarm_INDEL_VarRecal.txt
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
	echo "cd $VCF_DIR; java -Djava.io.tmpdir=/lscratch/\$SLURM_JOB_ID -Xmx64g -XX:ParallelGCThreads=\$SLURM_CPUS_PER_TASK -jar \$GATK_JAR -T VariantRecalibrator -R /data/Ostrander/Resources/cf31PMc.fa -input "$i".SNP.chrAll.vcf.gz -nt 24 -resource:indel2013,known=true,training=true,truth=true,prior=6.0 /data/Ostrander/Resources/cf31_ens-amy2_indels.vcf -an DP -an QD -an MQRankSum -an ReadPosRankSum -mode INDEL -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 --maxGaussians 4 -recalFile "$i".INDEL_recal.output.recal -tranchesFile "$i".INDEL_recal.output.tranches -rscriptFile "$i".INDEL_recal.output.plots.R; java -Djava.io.tmpdir=/lscratch/\$SLURM_JOB_ID -Xmx64g -XX:ParallelGCThreads=\$SLURM_CPUS_PER_TASK -jar \$GATK_JAR -T ApplyRecalibration -R /data/Ostrander/Resources/cf31PMc.fa -input "$i".SNP.chrAll.vcf.gz --ts_filter_level 99.0 -tranchesFile "$i".INDEL_recal.output.tranches -recalFile "$i".INDEL_recal.output.recal -mode INDEL -o "$i".SNP.INDEL.chrAll.vcf.gz" > swarm_INDEL_VarRecal.txt
done
more swarm_INDEL_VarRecal.txt
read -sp "`echo -e 'Press any key to continue or Ctrl+C to abort \n\b'`"
echo "Swarm JobID:"
swarm -f swarm_INDEL_VarRecal.txt -g 72 -t 26 --module GATK --time 24:00:00 --gres=lscratch:200 --logdir ~/job_outputs/gatk/VariantRecalibrator --sbatch "--mail-type=ALL,TIME_LIMIT_80"

#!/bin/bash
pwd=$(pwd)
cd ../../..
pwd_base=$(pwd)
cd $pwd
> swarm_BOTH_VarRecal.txt
###### INTERACTIVE SECTION ######
echo "What directory is the vcf file to be recalibrated in?"
read -e -p "Sample file directory: " VCF_DIR
echo "What do you want to name your swarm?"
read -e -p "Swarm name: " SWARM_NAME
######
cd $VCF_DIR
#ORIGINAL LINE DO NOT DELTE
find . -maxdepth 1 -name '*.chrAll.vcf.gz' -printf '%f\n' | sed 's/.chrAll.vcf.gz//' &> $pwd_base/tmp/gatk/vqsr.tmp
#find . -name '*.chr11.vcf.gz' -printf '%f\n' | sed 's/.chr11.vcf.gz//' &> $pwd_base/tmp/gatk/vqsr.tmp
cd $pwd_base/tmp/gatk/
IFS=,$'\n' read -d '' -r -a samplename < vqsr.tmp
#
cd $pwd
for i in "${samplename[@]}"
do
	echo "cd $VCF_DIR; java -Djava.io.tmpdir=/lscratch/\$SLURM_JOB_ID -Xmx64g -XX:ParallelGCThreads=\$SLURM_CPUS_PER_TASK -jar \$GATK_JAR -T VariantRecalibrator -R /data/Ostrander/Resources/cf31PMc.fa -input "$i".chrAll.vcf.gz -nt 24 -resource:hdchip,known=false,training=true,truth=true,prior=15.0 /data/Ostrander/Resources/CanineHD_num_order.vcf -resource:dbsnp,known=true,training=true,truth=false,prior=6.0 /data/Ostrander/Resources/CFA31_151.dbSNP_num_order.vcf -resource:axxelsson,known=true,training=false,truth=false,prior=6.0 /data/Ostrander/Resources/Axelsson.SNPs.num_order.vcf -an DP -an QD -an MQRankSum -an ReadPosRankSum -mode SNP -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 --maxGaussians 4 -recalFile "$i".SNP_recal.output.recal -tranchesFile "$i".SNP_recal.output.tranches -rscriptFile "$i".SNP_recal.output.plots.R; java -Djava.io.tmpdir=/lscratch/\$SLURM_JOB_ID -Xmx64g -XX:ParallelGCThreads=\$SLURM_CPUS_PER_TASK -jar \$GATK_JAR -T ApplyRecalibration -R /data/Ostrander/Resources/cf31PMc.fa -input "$i".chrAll.vcf.gz --ts_filter_level 99.0 -tranchesFile "$i".SNP_recal.output.tranches -recalFile "$i".SNP_recal.output.recal -mode SNP -o "$i"_SNP.chrAll.vcf.gz; java -Djava.io.tmpdir=/lscratch/\$SLURM_JOB_ID -Xmx64g -XX:ParallelGCThreads=\$SLURM_CPUS_PER_TASK -jar \$GATK_JAR -T VariantRecalibrator -R /data/Ostrander/Resources/cf31PMc.fa -input "$i"_SNP.chrAll.vcf.gz -nt 24 -resource:indel2013,known=true,training=true,truth=true,prior=6.0 /data/Ostrander/Resources/cf31_ens-amy2_indels.vcf -an DP -an QD -an MQRankSum -an ReadPosRankSum -mode INDEL -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 --maxGaussians 4 -recalFile "$i".INDEL_recal.output.recal -tranchesFile "$i".INDEL_recal.output.tranches -rscriptFile "$i".INDEL_recal.output.plots.R; java -Djava.io.tmpdir=/lscratch/\$SLURM_JOB_ID -Xmx64g -XX:ParallelGCThreads=\$SLURM_CPUS_PER_TASK -jar \$GATK_JAR -T ApplyRecalibration -R /data/Ostrander/Resources/cf31PMc.fa -input "$i"_SNP.chrAll.vcf.gz --ts_filter_level 99.0 -tranchesFile "$i".INDEL_recal.output.tranches -recalFile "$i".INDEL_recal.output.recal -mode INDEL -o "$i".SNP.INDEL.chrAll.vcf.gz" > swarm_BOTH_VarRecal.txt
done
more swarm_BOTH_VarRecal.txt
read -sp "`echo -e 'Press any key to continue or Ctrl+C to abort \n\b'`"
echo "Swarm JobID:"
swarm -f swarm_BOTH_VarRecal.txt -g 72 -t 26 --module GATK --time 4:00:00 --gres=lscratch:200 --logdir ~/job_outputs/gatk/VariantRecalibrator --sbatch "--mail-type=ALL,TIME_LIMIT_80 --job-name $SWARM_NAME"

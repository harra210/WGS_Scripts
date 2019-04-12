#!/bin/bash
#This script is to create an interval list from a reference file.
#Our reference file is CanFam 3.1 and the plan is to bin by splitting chr38 by a half and then by half again  and then use that number to create the binning interval
#That number is 5978635
pwd=$(pwd)
### INTERACTIVE SECTION ###
echo "Where do you want to output your Interval List?"
read -e -p "Output Location (Make sure to include tailing /): " OUTPUT
echo "What do you want to call your Interval List?"
read -e -p "List Name: " NAME
echo "What do you want to call your swarm?"
read -e -p "Swarm name: " SWARM_NAME
### END INTERACTIVE ###
> Preprocessintervals.swarm
echo "cd $pwd; gatk PreprocessIntervals -R /data/Ostrander/Resources/cf31PMc.fa --bin-length 2989318 --padding 0 -O "$OUTPUT""$NAME".interval_list" >> Preprocessintervals.swarm
more Preprocessintervals.swarm
read -sp "`echo -e 'Verify swarm, press enter to continue or Ctrl+C to abort \n\b'`" -n1 key
echo "Swarm Job ID"
swarm -f Preprocessintervals.swarm -g 4 --time 60:00 --module GATK/4.1.0.0 --logdir ~/job_outputs/troubleshooting_scripts/Preprocessintervals --sbatch "--mail-type=ALL,TIME_LIMIT_90 --partition=quick --job-name $SWARM_NAME"

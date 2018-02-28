#!/bin/bash
#
# Author      Kushal Datta
# Created on  January 4th, 2018
# About       Runs tf_cnn_benchmarks.py with MCNN on multiple nodes
#

#sudo cpupower frequency-info
#sudo cpupower frequency-set -d 2.1G -u 3.7G -g performance

./kill_multiple_workers.sh

#itr=22734
itr=5000
data_dir=/data01/kushal/novartis/mcnn
script_home=/home/bduser/kushal/benchmarks/scripts/tf_cnn_benchmarks
script=$script_home/tf_cnn_benchmarks.py

thr=9
bs=8

ps=localhost
pshost='localhost:2221'
#worker_hosts='skx07-opa:2222,skx07-opa:2223,skx07-opa:2224,skx07-opa:2225'
worker_hosts='localhost:2222,localhost:2223,localhost:2224,localhost:2225'

results_dir='/tmp/tf_cnn_benchmarks/results_'
results_dir+=`date +"%H%M%S%m%d%y"`

# SSH command
run_instance() {
	job_name=$1
        host=$2
        log=$3
        task_index=$4
        kmp_affinity=$5
        numactl=$6
	echo $job_name,$host,$log,$task_index,$kmp_affinity,$numactl,$pshost
        ssh $host << EOF
		mkdir -p $results_dir
                unset http_proxy
                unset https_proxy
                export OMP_NUM_THREADS=$thr
                nohup $numactl python $script \
                        --model=mcnn \
                        --batch_size=$bs \
                        --data_format=NCHW \
                        --data_dir=$data_dir \
                        --data_name=mcnn \
                        --num_intra_threads=8 \
                        --num_inter_threads=8 \
                        --num_batches=$itr \
                        --num_warmup_batches=5 \
                        --display_every=5 \
                        --learning_rate=0.001 \
                        --momentum=0.9 \
                        --weight_decay=0.0002 \
                        --optimizer=momentum \
                        --resize_method=bilinear \
                        --distortions=False \
                        --trace_file='$results_dir/mcnn-trace' \
                        --sync_on_finish=False \
                        --device=cpu \
                        --mkl=True \
                        --kmp_affinity='$kmp_affinity' \
                        --ps_hosts=$pshost \
                        --worker_hosts=$worker_hosts \
                        --job_name=$job_name \
                        --task_index=$task_index > $log 2>&1 &
EOF
        echo "Writing to log: $log"
}

#remote_copy_scripts

#    KMP_AFFINITY="granularity=fine,explicit,proclist=[0-19,40-59]"
KMP_AFFINITY_1="granularity=fine,explicit,proclist=[0-9,40-49]"
KMP_AFFINITY_2="granularity=fine,explicit,proclist=[10-19,50-59]"
KMP_AFFINITY_3="granularity=fine,explicit,proclist=[20-29,60-69]"
KMP_AFFINITY_4="granularity=fine,explicit,proclist=[30-39,70-79]"

run_instance "ps" $ps "$results_dir/ps.out" 0

run_instance 'worker' localhost "$results_dir/worker-0.out" 0 $KMP_AFFINITY_1 "numactl -m 0"
run_instance 'worker' localhost "$results_dir/worker-1.out" 1 $KMP_AFFINITY_2 "numactl -m 0"
run_instance 'worker' localhost "$results_dir/worker-2.out" 2 $KMP_AFFINITY_3 "numactl -m 1"
run_instance 'worker' localhost "$results_dir/worker-3.out" 3 $KMP_AFFINITY_4 "numactl -m 1"

tail -100f $results_dir/worker-0.out
#tail -100f $results_dir/ps.out

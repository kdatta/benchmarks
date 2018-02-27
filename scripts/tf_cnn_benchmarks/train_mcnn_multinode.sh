#!/bin/bash
#
# Author      Kushal Datta
# Created on  January 4th, 2018
# About       Runs tf_cnn_benchmarks.py with MCNN on multiple nodes
#

#sudo cpupower frequency-info
#sudo cpupower frequency-set -d 2.1G -u 3.7G -g performance

#itr=22734
itr=50
data_dir=/data01/kushal/novartis/mcnn/train-images/
script_home=/home/bduser/kushal/benchmarks/scripts/tf_cnn_benchmarks
script=$script_home/tf_cnn_benchmarks.py

thr=36
bs=8

ps=skx05-opa
#workers='skx06-opa skx07-opa skx08-opa skx09-opa'
workers='skx06-opa skx07-opa skx08-opa skx10-opa skx11-opa skx12-opa'
ps_host='skx05-opa:2222'
#worker_hosts='skx06-opa:2222,skx07-opa:2222,skx08-opa:2222,skx09-opa:2222'
worker_hosts='skx06-opa:2222,skx07-opa:2222,skx08-opa:2222,skx10-opa:2222,skx11-opa:2222,skx12-opa:2222'

# Remote copy python/bash scripts
remote_copy_scripts() {
        cd $script_home
        git pull upstream mcnn
        #rsync -avz --exclude '*.sw*' $script_home $ps:$script_home/../
        for w in $workers
        do
        #        if [ "$w" != "$HOSTNAME" ]
        #        then
        #                rsync -avz --exclude '*.sw*' $script_home $w:$script_home/../
        #        fi
            cd $script_home
            git pull upstream mcnn
        done
}

# SSH command
run_instance() {
        if [ "$1" == "ps" ]
        then
                job_name=ps
        else
                job_name=worker
        fi

        host=$2
        log=$3
        task_index=$4
        ssh $host << EOF
                mkdir -p $results_dir
                unset HTTP_PROXY
                unset HTTPS_PROXY
                unset http_proxy
                unset https_proxy
                sh $script_home/kill_local.sh
                export OMP_NUM_THREADS=$thr
                nohup numactl -l python $script \
                        --model=mcnn \
                        --batch_size=$bs \
                        --data_format=NCHW \
                        --data_dir=$data_dir \
                        --data_name='mcnn' \
                        --num_intra_threads=$thr \
                        --num_inter_threads=32 \
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
                        --kmp_affinity=$KMP_AFFINITY \
                        --ps_hosts=$ps_host \
                        --worker_hosts=$worker_hosts \
                        --job_name=$job_name \
                        --task_index=$task_index \
                        --variable_update='parameter_server' > $log 2>&1 &
EOF
        echo "Writing to log: $log"
}

results_dir='/tmp/tf_cnn_benchmarks/results_'
results_dir+=`date +"%H%M%S%m%d%y"`

remote_copy_scripts

#    KMP_AFFINITY="granularity=fine,explicit,proclist=[0-19,40-59]"
KMP_AFFINITY="granularity=fine,compact,1,0"

run_instance "ps" $ps "$results_dir/ps.out" 0

count=0

for w in $workers
do
echo $w
        run_instance 'worker' $w "$results_dir/worker-${count}.out" $count
        count=$((count+1))
done

ssh $ps_host "tail $results_dir/ps.out"
tail -100f $results_dir/worker-*.out

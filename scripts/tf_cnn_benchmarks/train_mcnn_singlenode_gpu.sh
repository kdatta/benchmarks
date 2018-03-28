#!/bin/bash

#for multi-node testing
#cat node_list; source setup_multinode.sh; echo $LSB_HOSTS; cat node_list | wc; echo $LSB_MAX_NUM_PROCESSORS

#===============================================================================
#sudo cpupower frequency-info
#sudo cpupower frequency-set -d 2.1G -u 3.7G -g performance
#echo "Clear cache"
#sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
#echo "Caches cleared"
#echo ""
#date
#echo "cat imagenet data"
#cat /home/deepthi/TF_Records/* > /dev/null
#echo "done: cat of imagenet data"
#date

#itr=22734
itr=9000
data_dir=/raid/kushal/mcnn
#data_dir=/data01/TF_MCNN

#numactl -m 0 cat $data_dir/* > /dev/null
#numactl -m 1 cat $data_dir/* > /dev/null

for thr in 36 ; do
  for bs in 8 ; do
#    KMP_AFFINITY="granularity=fine,explicit,proclist=[0-3,40-43]"
    KMP_AFFINITY="granularity=fine,compact,1,0"
    export OMP_NUM_THREADS=$thr
    python tf_cnn_benchmarks.py --model=mcnn \
            --batch_size=$bs \
            --data_format=NCHW \
            --data_dir=$data_dir \
            --data_name=mcnn \
            --num_intra_threads=$thr \
            --num_inter_threads=32 \
            --num_batches=$itr \
            --num_warmup_batches=5 \
            --display_every=5 \
            --learning_rate=0.001  \
            --momentum=0.9 \
            --weight_decay=0.0 \
            --optimizer=momentum \
            --resize_method=bilinear \
            --distortions=False \
            --trace_file='/tmp/tf_cnn_benchmarks/results/mcnn-trace' \
            --sync_on_finish=True \
            --num_gpus=7 \
            --summary_verbosity=0 \
            --save_summaries_steps=0 \
            --train_dir='/tmp/tf_cnn_benchmarks/eval' \
            --variable_update='parameter_server' \
            --all_reduce_spec='pscpu'

  done
done


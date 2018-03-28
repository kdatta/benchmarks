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
data_dir=/raid/data/imagenet_tf
num_gpus=7

for thr in 36 ; do
  for bs in 32 ; do
    python tf_cnn_benchmarks.py --model=resnet50 \
            --batch_size=$bs \
            --data_format=NCHW \
            --data_dir=$data_dir \
#            --data_name=imagenet \
#            --num_batches=$itr \
            --num_warmup_batches=50 \
            --display_every=5 \
            --learning_rate=0.001  \
            --momentum=0.9 \
            --weight_decay=0.0 \
            --optimizer=sgd \
            --resize_method=bilinear \
            --distortions=False \
            --trace_file='/tmp/tf_cnn_benchmarks/results/mcnn-trace' \
            --sync_on_finish=True \
            --num_gpus=$num_gpus \
            --summary_verbosity=0 \
            --save_summaries_steps=0 \
            --train_dir='/tmp/tf_cnn_benchmarks/resnet50/eval' \
            --variable_update='parameter_server'

  done
done


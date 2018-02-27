#!/bin/bash

#for multi-node testing
#cat node_list; source setup_multinode.sh; echo $LSB_HOSTS; cat node_list | wc; echo $LSB_MAX_NUM_PROCESSORS

#===============================================================================
sudo cpupower frequency-info
sudo cpupower frequency-set -d 2.1G -u 3.7G -g performance
#echo "Clear cache"
#sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
#echo "Caches cleared"
#echo ""
#date
#echo "cat imagenet data"
#cat /home/deepthi/TF_Records/* > /dev/null
#echo "done: cat of imagenet data"
#date

itr=22734
#itr=50
data_dir=/data01/kushal/novartis/mcnn/train-images

for thr in 32 ; do
  for bs in 8 ; do
    echo "" 
    echo "**********NUM_OMP_THREADS $thr **********" 
    #numactl -l python tf_cnn_benchmarks_MKL.py --cpu skl --model googlenet --batch_size $bs --data_format NCHW --data_dir /home/deepthi/TF_Records --data_name imagenet --num_intra_threads $thr --num_inter_threads 2 --num_omp_threads $thr --num_batches 40
#    KMP_AFFINITY="granularity=fine,explicit,proclist=[0-19,40-59]"
    KMP_AFFINITY="granularity=fine,compact,1,0"
    export OMP_NUM_THREADS=$thr
    numactl -l python tf_cnn_benchmarks.py --model mcnn --batch_size $bs --data_format NCHW --data_dir $data_dir --data_name 'mcnn' --num_intra_threads 16 --num_inter_threads 8 --num_batches $itr --num_warmup_batches 5  --display_every 5 --learning_rate 0.001  --momentum 0.9 --weight_decay 0.0002 --optimizer momentum --resize_method bilinear --distortions False --trace_file '/tmp/tf_cnn_benchmarks/results/mcnn-trace' --sync_on_finish False --device cpu --mkl True --kmp_affinity $KMP_AFFINITY
  done
done
#===============================================================================

#python tf_cnn_benchmarks_MKL.py --model alexnet --batch_size 256 --data_format NCHW --num_intra_threads 44 --num_inter_threads 1 --trace_file alexnet.json
#python tf_cnn_benchmarks_MKL.py --model googlenet --batch_size 256 --data_format NCHW --num_intra_threads 44 --num_inter_threads 2 --trace_file googlenet.json
#python tf_cnn_benchmarks_MKL.py --model vgg11 --batch_size 128 --data_format NCHW --num_intra_threads 44 --num_inter_threads 1 --trace_file vgg.json
#python tf_cnn_benchmarks_MKL.py --model inception3 --batch_size 32 --data_format NCHW --num_intra_threads 44 --num_inter_threads 2 --trace_file inception.json
#python tf_cnn_benchmarks_MKL.py --model resnet50 --batch_size 32 --data_format NCHW --num_intra_threads 44 --num_inter_threads 2 --trace_file resnet.json
#python tf_cnn_benchmarks


# Run the following commands on host_0 (10.0.0.1):
python tf_cnn_benchmarks.py \
--batch_size=64 --model=resnet50 --variable_update=distributed_replicated \
--job_name=worker --ps_hosts=10.100.11.48:50000,10.100.11.49:50000 \
--worker_hosts=10.100.11.48:50000,10.100.11.49:50000 --task_index=1

python tf_cnn_benchmarks.py \
--batch_size=64 --model=resnet50 --variable_update=distributed_replicated \
--job_name=ps --ps_hosts=10.100.11.48:50000,10.100.11.49:50000 \
--worker_hosts=10.100.11.48:50000,10.100.11.49:50000 --task_index=1

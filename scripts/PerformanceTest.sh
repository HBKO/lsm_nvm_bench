#!/bin/sh
# 数据信息
value_array=(4096)
GB="`expr 1024 \* 1024 \* 1024`"
# 80GB 4
test_all_size="`expr 4 \* 1024 \* 1024 \* 1024`"
#test_all_size="`expr 3000 \* 1024 \* 1024`"




# 存储路径
# SSD
bench_db_path="/SSD/ayj_lsm_nvm/"
# 有用PM,这个路径改成PM路径，只有SSD，路径就改成SSD路径
wal_dir="/pmem0/ayj/"
bench_value="4096"
bench_compression="none" #"snappy,none"

# 读写模式
bench_benchmarks=("fillrandom") # test multi benchmark:""
this_benchmarks="fillrandom"


bench_num="20000000"
bench_readnum="1000000"
threads="1"

#是否使用日志
disable_wal="false"

# 层次数等相关信息
max_write_buffer_number="13"
# write_buffer_size="`expr 2 \* 1024 \* 1024 \* 1024`"
level0_file_num_compaction_trigger="30"
level0_slowdown_writes_trigger="30"
level0_stop_writes_trigger="50"

# 当前配置是一半PMEM，一半SSD

# nvm配置参数
use_nvm="false"
pmem_path="/pmem0/ayj/"
pmem_dir_path="/pmem0/ayj/"
recovery="false"
max_immutable_num="5"
flush_memtable_nums="1"
# 阻塞信息
nvm_memtable_slowdown_bytes="104857600"
nvm_memtable_stop_bytes="52428800"
nvm_level0_slowdown_bytes="`expr 10 \* 1024 \* 1024 \* 1024`"
nvm_level0_stop_bytes="`expr 15 \* 1024 \* 1024 \* 1024`"

bench_target="out-static/db_bench"
benchmark_result="Test_result"
result_path="Test_result"

# 删除掉的额外参数

RUN_ONE_TEST() {
    echo "pmem_path is $pmem_path"
    const_params="
    --threads=1 \
    --write_buffer_size=$DRAMBUFFSZ \
    --nvm_buffer_size=$NVMBUFFSZ \
    --db_disk=$bench_db_path \
    --value_size=$bench_value \
    --benchmarks=$bench_benchmarks \
    --num=$bench_num \
    --num_read_threads=1 \
    "
    cmd="numactl -N 0 $bench_target $const_params >> $benchmark_result/TthisOut.out 2>&1"
    echo $cmd > processLog.out
    echo $cmd
    eval $cmd
}

CLEAN_DATA() {
    # delete some log file and dir path
    sleep 1
    rm -rf $pmem_dir_path/*
    rm -rf $bench_db_path/*
    sync
    sleep 1

    # clear cache message
}

COPY_OUT_FILE() {
    mkdir $result_path > /dev/null 2>&1
    #mkdir $result_path/resultTest
    FilenameSuffix=""
    if [ "$use_nvm" == "true" ]; then
        FilenameSuffix="NVM_$bench_value+$bench_num+$bench_benchmarks"
        echo "$FilenameSuffix"
    else
        FilenameSuffix="NOVELSM_$bench_value+$bench_num+$bench_benchmarks"
    fi
    cp -r NVM_LOG $result_path/NVM_LOG$FilenameSuffix
    cp -r OP_TIME.csv $result_path/OP_TIME$FilenameSuffix.csv
    cp -r PerSecondLatency.csv $result_path/PerSecondLatency$FilenameSuffix.csv
    cp -r Latency.csv $result_path/Latency$FilenameSuffix.csv
    cp -r $benchmark_result/thisOut.out $result_path/FinalOut$FilenameSuffix.out
}


RUN_ALL_TEST() {
    for value in ${value_array[@]}; do 
        for benchMode in ${bench_benchmarks[@]}; do
            CLEAN_DATA
            bench_value="$value"
            bench_num="`expr $test_all_size / $bench_value`"
            this_benchmarks=$benchMode

            RUN_ONE_TEST
            
            if [ $? -ne 0 ];then
                exit 1
            fi
            COPY_OUT_FILE
            sleep 1
        done
    done
}


RUN_ALL_TEST

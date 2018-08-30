#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"
TerarkTemp=$DIR/terark-temp
ConfigFile=$DIR/conf/pika.conf
TerarkPath=$DIR/../terark-zip-rocksdb/pkg/terark-zip-rocksdb-Linux-x86_64-g++-5.4-bmi2-0/lib

if [ ! -d "$TerarkTemp" ]; then
    echo TerarkTemp = "$TerarkTemp" does not exit or is not a directory
    exit 1
fi

TerarkEnv="env TerarkZipTable_localTempDir=$TerarkTemp \
          TerarkZipTable_keyPrefixLen=4 \
          TerarkZipTable_oldOffsetOf=0 \
          TerarkZipTable_enable_partial_remove=1 \
          TerarkZipTable_offsetArrayBlockUnits=128 \
          TerarkZipTable_indexCacheRatio=0 \
          TerarkZipTable_sampleRatio=0.02 \
          TerarkZipTable_extendedConfigFile=$DIR/license \
          TerarkZipTable_write_buffer_size=2G \
          TerarkZipTable_target_file_size_base=10G \
          TerarkZipTable_level0_file_num_compaction_trigger=5 \
          TerarkZipTable_level0_slowdown_writes_trigger=30 \
          TerarkZipTable_level0_stop_writes_trigger=60 \
          TerarkZipTable_max_subcompactions=1 \
          TerarkZipTable_warmUpIndexOnOpen=0 \
          Terark_enableChecksumVerify=0 \
          TerarkUseDivSufSort=1"

if [ -z "$1" ]; then
    ${TerarkEnv} ${DIR}/output/bin/pika -c ${ConfigFile}
else 
    if [ "$1" == "dynamic" ]; then
        ${TerarkEnv} LD_LIBRARY_PATH=$TerarkPath LD_PRELOAD=libterark-zip-rocksdb-r.so ${DIR}/output/bin/pika -c ${ConfigFile}
    else
        echo usage {./$0 | ./$0 dynamic}
    fi
fi

#!/usr/bin/env bash
if [ -z "$1" ]; then
	echo usage $0 with/without
	exit 0
fi

WITH_TERARK=/home/terark/workspace/terark-zip-rocksdb
LOCAL_TEMP_DIR=/home/terark/workspace/pika-on-terarkdb/pika-on-terarkdb/localTempDir
export LD_LIBRARY_PATH=$WITH_TERARK/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/home/terark/workspace/pika-on-terarkdb/third/nemo/output/lib:$LD_LIBRARY_PATH

set -x

if [ "$1" == "with" ]; then
	mkdir -p $LOCAL_TEMP_DIR
	env	LD_PRELOAD=libterark-zip-rocksdb-r.so:librocksdb.so	\
		TerarkZipTable_localTempDir=$LOCAL_TEMP_DIR		\
		./output/bin/pika					\
		-c ./conf/pika-on-terarkdb.conf
elif [ "$1" == "without" ]; then
	env	LD_PRELOAD=librocksdb.so				\
		./output/bin/pika					\
		-c ./conf/pika.conf
else
	echo usage $0 with/without
	exit 0
fi

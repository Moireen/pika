#!/bin/bash
PATH_TO_pika=/home/terark/workspace/pika-on-terarkdb
WITH_TERARK=/home/terark/workspace/terark-zip-rocksdb

rm -rf $PATH_TO_pika/pikatests/src/db
rm -rf $PATH_TO_pika/pikatests/src/log

mkdir -p $PATH_TO_pika/pikatests/src
mkdir -p $PATH_TO_pika/pikatests/tests/assets
cp $PATH_TO_pika/output/bin/pika $PATH_TO_pika/pikatests/src/redis-server
cp $PATH_TO_pika/output/conf/pika.conf $PATH_TO_pika/pikatests/tests/assets/default.conf

export LD_LIBRARY_PATH=$WITH_TERARK/lib:$LIB_LIBRARY_PATH
export LD_LIBRARY_PATH=/home/terark/workspace/pika-on-terarkdb/third/nemo/output/lib:$LD_LIBRARY_PATH

LocalTempDir=$PATH_TO_pika/pikatests/src/localTempDir
mkdir -p ${LocalTempDir}

env LD_PRELOAD=libterark-zip-rocksdb-r.so:librocksdb.so \
	TerarkZipTable_localTempDir=$LocalTempDir \
	tclsh tests/test_helper.tcl \
		--clients 1


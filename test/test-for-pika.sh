#!/usr/bin/env bash
if [ -z "$1" ]; then
	echo usage $0 \[-t\] -m num_mget_keys -n num_requests -c num_clients -k key_filename -v value_filename set/get
        exit 0
fi

mgets=10
requests=100000
clients=50
value_size=2
PIKA=pika
while getopts ":m:n:c:k:h:v:t" optname; do
        case "$optname" in
		"t")
			PIKA=pika-on-terarkdb
			;;
                "n")
                        requests=$OPTARG
                        ;;
                "c")
                        clients=$OPTARG
                        ;;
                "k")
                        key_filename=$OPTARG
                        ;;
                "m")
                        mgets=$OPTARG
                        ;;
		"v")
			value_filename=$OPTARG
			;;
        esac
done
shift $((OPTIND-1))


REDIS_DIR=/home/terark/workspace/redis-3.2.8
REDIS_BENCHMARK_DIR=$REDIS_DIR/src
REDIS_CLI_DIR=$REDIS_DIR/src
RESULT_FILE_SET=${PIKA}_set.result
RESULT_FILE_GET=${PIKA}_get.result

set -x

if [ "$1" == "set" ]; then
	echo ====== FLUSHALL ====== > $RESULT_FILE_SET
	$REDIS_CLI_DIR/redis-cli -h 127.0.0.1 -p 9221 <<< "flushall" >> $RESULT_FILE_SET
	echo >> $RESULT_FILE_SET
	$REDIS_BENCHMARK_DIR/redis-benchmark -h 127.0.0.1 -p 9221 -t set -n $requests -c $clients --key_file $key_filename --value_file $value_filename >> $RESULT_FILE_SET
	echo ====== COMPACT ====== >> $RESULT_FILE_SET
	du -h ./$PIKA/db/kv >> $RESULT_FILE_SET
	$REDIS_CLI_DIR/redis-cli -h 127.0.0.1 -p 9221 <<< "compact sync" >> $RESULT_FILE_SET
	du -h ./$PIKA/db/kv >> $RESULT_FILE_SET
	echo >> $RESULT_FILE_SET
elif [ "$1" == "get" ]; then
	$REDIS_BENCHMARK_DIR/redis-benchmark -h 127.0.0.1 -p 9221 -t get -n $requests -c $clients --key_file $key_filename> $RESULT_FILE_GET
	
	$REDIS_BENCHMARK_DIR/redis-benchmark -h 127.0.0.1 -p 9221 -t mget_$mgets -n $requests -c $clients --key_file $key_filename>> $RESULT_FILE_GET
fi

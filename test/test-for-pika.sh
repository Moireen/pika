#!/usr/bin/env bash
if [ -z "$1" ]; then
	echo usage $0 \[-t\] -m num_mget_keys -n num_requests -c num_clients -d value_size -f values_filename set/get
        exit 0
fi

mgets=10
requests=100000
clients=50
value_size=2
PIKA=pika
while getopts ":m:n:c:d:h:f:t" optname; do
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
                "d")
                        value_size=$OPTARG
                        ;;
                "m")
                        mgets=$OPTARG
                        ;;
		"f")
			filename=$OPTARG
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
	if [ -z "$filename" ]; then
		$REDIS_BENCHMARK_DIR/redis-benchmark -h 127.0.0.1 -p 9221 -t set -r 100000000000 -n $requests -c $clients -d $value_size >> $RESULT_FILE_SET
	else
		$REDIS_BENCHMARK_DIR/redis-benchmark -h 127.0.0.1 -p 9221 -t set -r 100000000000 -n $requests -c $clients -d $value_size --filename $filename >> $RESULT_FILE_SET
	fi
	echo ====== COMPACT ====== >> $RESULT_FILE_SET
	du -h ./$PIKA/db/kv >> $RESULT_FILE_SET
	$REDIS_CLI_DIR/redis-cli -h 127.0.0.1 -p 9221 <<< "compact sync" >> $RESULT_FILE_SET
	du -h ./$PIKA/db/kv >> $RESULT_FILE_SET
	echo >> $RESULT_FILE_SET
elif [ "$1" == "get" ]; then
	$REDIS_BENCHMARK_DIR/redis-benchmark -h 127.0.0.1 -p 9221 -t get -r 100000000000 -n $requests -c $clients -d $value_size > $RESULT_FILE_GET
	
	$REDIS_BENCHMARK_DIR/redis-benchmark -h 127.0.0.1 -p 9221 -t mget_$mgets -r 10000000000 -n $requests -c $clients -d $value_size >> $RESULT_FILE_GET
fi

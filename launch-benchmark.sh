#!/bin/bash

# Script that launches a set of Jobs for benchmarking Pangool against Hadoop, Crunch (with Avro) and Cascading

#
# Need to have pangool-examples and pangool-benchmark job JARs in the folder where this is launched.
# The folder needs to have enough disk space e.g. /mnt on master EC2 nodes
# The cluster needs to run CDH3, otherwise Crunch won't work
# If you want to disable HDFS permissions you can set dfs.permissions = false in the Hadoop conf and restart the NameNode
#

PANGOOL_EXAMPLES_JAR=pangool-examples-0.40-job.jar
PANGOOL_BENCHMARK_JAR=pangool-benchmark-0.40-SNAPSHOT-job.jar

# Generate input data

hadoop jar $PANGOOL_EXAMPLES_JAR secondarysort_gen_data secondarysort-1.txt 100 100 1000
hadoop jar $PANGOOL_EXAMPLES_JAR secondarysort_gen_data secondarysort-2.txt 200 200 2000
hadoop jar $PANGOOL_EXAMPLES_JAR secondarysort_gen_data secondarysort-3.txt 300 300 3000

hadoop fs -put secondarysort* .
rm secondarysort*

hadoop jar $PANGOOL_BENCHMARK_JAR wordcount_gen_data wordcount-1.txt 1000000 50 4
hadoop jar $PANGOOL_BENCHMARK_JAR wordcount_gen_data wordcount-2.txt 5000000 50 4
hadoop jar $PANGOOL_BENCHMARK_JAR wordcount_gen_data wordcount-3.txt 10000000 50 4

hadoop fs -put wordcount* .
rm wordcount*

hadoop jar $PANGOOL_EXAMPLES_JAR url_resolution_gen_data url-map-1.txt url-reg-1.txt 1000 10 1000
hadoop jar $PANGOOL_EXAMPLES_JAR url_resolution_gen_data url-map-2.txt url-reg-2.txt 5000 10 1000
hadoop jar $PANGOOL_EXAMPLES_JAR url_resolution_gen_data url-map-3.txt url-reg-3.txt 10000 10 1000

hadoop fs -put url-*txt .
rm url-*

# Run URL resolution

hadoop jar $PANGOOL_EXAMPLES_JAR url_resolution url-map-1.txt url-reg-1.txt out-pangool-url-1
hadoop jar $PANGOOL_BENCHMARK_JAR hadoop-urlresolution url-map-1.txt url-reg-1.txt out-hadoop-url-1
hadoop jar $PANGOOL_BENCHMARK_JAR cascading-urlresolution url-map-1.txt url-reg-1.txt out-cascading-url-1
hadoop jar $PANGOOL_BENCHMARK_JAR crunch-urlresolution url-map-1.txt url-reg-1.txt out-crunch-url-1

hadoop jar $PANGOOL_EXAMPLES_JAR url_resolution url-map-2.txt url-reg-2.txt out-pangool-url-2
hadoop jar $PANGOOL_BENCHMARK_JAR hadoop-urlresolution url-map-2.txt url-reg-2.txt out-hadoop-url-2
hadoop jar $PANGOOL_BENCHMARK_JAR cascading-urlresolution url-map-2.txt url-reg-2.txt out-cascading-url-2
hadoop jar $PANGOOL_BENCHMARK_JAR crunch-urlresolution url-map-2.txt url-reg-2.txt out-crunch-url-2

hadoop jar $PANGOOL_EXAMPLES_JAR url_resolution url-map-3.txt url-reg-3.txt out-pangool-url-3
hadoop jar $PANGOOL_BENCHMARK_JAR hadoop-urlresolution url-map-3.txt url-reg-3.txt out-hadoop-url-3
hadoop jar $PANGOOL_BENCHMARK_JAR cascading-urlresolution url-map-3.txt url-reg-3.txt out-cascading-url-3
hadoop jar $PANGOOL_BENCHMARK_JAR crunch-urlresolution url-map-3.txt url-reg-3.txt out-crunch-url-3

# Run secondary sort

hadoop jar $PANGOOL_EXAMPLES_JAR secondarysort secondarysort-1.txt out-pangool-s-s-1
hadoop jar $PANGOOL_BENCHMARK_JAR crunch-secondarysort secondarysort-1.txt out-crunch-s-s-1
hadoop jar $PANGOOL_BENCHMARK_JAR cascading-secondarysort secondarysort-1.txt out-cascading-s-s-1
hadoop jar $PANGOOL_BENCHMARK_JAR hadoop-secondarysort secondarysort-1.txt out-hadoop-s-s-1

hadoop jar $PANGOOL_EXAMPLES_JAR secondarysort secondarysort-2.txt out-pangool-s-s-2
hadoop jar $PANGOOL_BENCHMARK_JAR crunch-secondarysort secondarysort-2.txt out-crunch-s-s-2
hadoop jar $PANGOOL_BENCHMARK_JAR cascading-secondarysort secondarysort-2.txt out-cascading-s-s-2
hadoop jar $PANGOOL_BENCHMARK_JAR hadoop-secondarysort secondarysort-2.txt out-hadoop-s-s-2

hadoop jar $PANGOOL_EXAMPLES_JAR secondarysort secondarysort-3.txt out-pangool-s-s-3
hadoop jar $PANGOOL_BENCHMARK_JAR crunch-secondarysort secondarysort-3.txt out-crunch-s-s-3
hadoop jar $PANGOOL_BENCHMARK_JAR cascading-secondarysort secondarysort-3.txt out-cascading-s-s-3
hadoop jar $PANGOOL_BENCHMARK_JAR hadoop-secondarysort secondarysort-3.txt out-hadoop-s-s-3

# Run Word count

hadoop jar $PANGOOL_BENCHMARK_JAR hadoop-wordcount wordcount-1.txt out-hadoop-w-c-1
hadoop jar $PANGOOL_BENCHMARK_JAR pangool-wordcount wordcount-1.txt out-pangool-w-c-1
hadoop jar $PANGOOL_BENCHMARK_JAR cascading-wordcount wordcount-1.txt out-cascading-w-c-1
hadoop jar $PANGOOL_BENCHMARK_JAR crunch-wordcount wordcount-1.txt out-crunch-w-c-1

hadoop jar $PANGOOL_BENCHMARK_JAR hadoop-wordcount wordcount-2.txt out-hadoop-w-c-2
hadoop jar $PANGOOL_BENCHMARK_JAR pangool-wordcount wordcount-2.txt out-pangool-w-c-2
hadoop jar $PANGOOL_BENCHMARK_JAR cascading-wordcount wordcount-2.txt out-cascading-w-c-2
hadoop jar $PANGOOL_BENCHMARK_JAR crunch-wordcount wordcount-2.txt out-crunch-w-c-2

hadoop jar $PANGOOL_BENCHMARK_JAR hadoop-wordcount wordcount-3.txt out-hadoop-w-c-3
hadoop jar $PANGOOL_BENCHMARK_JAR pangool-wordcount wordcount-3.txt out-pangool-w-c-3
hadoop jar $PANGOOL_BENCHMARK_JAR cascading-wordcount wordcount-3.txt out-cascading-w-c-3
hadoop jar $PANGOOL_BENCHMARK_JAR crunch-wordcount wordcount-3.txt out-crunch-w-c-3


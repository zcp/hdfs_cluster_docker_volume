#!/bin/bash
#test the hadoop cluster by running wordcount

# create input files 
mkdir input
echo "Hello Docker" >input/file2.txt
echo "Hello Hadoop" >input/file1.txt

# create input directory on HDFS
hadoop fs -mkdir -p input

# put input files to HDFS
hdfs dfs -put ./input/* input

#show input directory on hdfs
hadoop fs -ls input

################################
#test if data in slaves are persistent.
#stop hadoop-master, hadoop-slave1,2,3
docker stop hadoop-master
docker stop hadoop-slave1
docker stop hadoop-slave2
docker stop hadoop-slave3

##stop hadoop-master, hadoop-slave1,2,3 
docker start hadoop-master
docker start hadoop-slave1
docker start hadoop-slave2
docker start hadoop-slave3

docker exec -it hadoop-master bash
#don't hdfs namenode -format, if so, all data will be lost.
start-dfs.sh
hdfs dfs -cat input/file1.txt

#if you can see  the content of file1, that data in volumes that are mounted inside hadoop-slave1,2,3 are persistent.
####################################3
]

# run wordcount 
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/sources/hadoop-mapreduce-examples-2.7.2-sources.jar org.apache.hadoop.examples.WordCount input output

# print the input files
echo -e "\ninput file1.txt:"
hdfs dfs -cat input/file1.txt

echo -e "\ninput file2.txt:"
hdfs dfs -cat input/file2.txt

# print the output of wordcount
echo -e "\nwordcount output:"
hdfs dfs -cat output/part-r-00000

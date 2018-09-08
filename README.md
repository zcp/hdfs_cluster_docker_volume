# hadoop_cluster-docker
2. #build an image for hadoop from a dockerfile
   docker build -t hadoop .

3. create config files
   bootstrap.sh, ssh_config, sshd_config, slaves, core-site.xml, hdfs-site.xml, mapred-sit.xml,yarn-site.xml

4.create a network for hadoop cluster
  docker network create --driver=bridge hadoop

5. create hadoop master
    docker rm -f hadoop-master 
    docker run -itd --net=hadoop -p 50070:50070 -p 8088:8088 -v name-node:/hadoop/dfs/name --name hadoop-master --hostname   hadoop-master hadoop

6. create hadoop slave1,2,3
   docker run -itd --net=hadoop  -v data-node1:/hadoop/dfs/data --name hadoop-slave1 --hostname hadoop-slave1 hadoop &> /dev/null 
   docker run -itd --net=hadoop  -v data-node2:/hadoop/dfs/data --name hadoop-slave2 --hostname hadoop-slave2 hadoop &> /dev/null 
   docker run -itd --net=hadoop  -v data-node3:/hadoop/dfs/data --name hadoop-slave3 --hostname hadoop-slave3 hadoop &> /dev/null 

7. login hadoop-master
   docker exec -it hadoop-master bash

8. hdfs namenode -format

9. start-dfs.sh

10. start-yarn.sh

11. get hadoop-master's ip
  docker inspect hadoop-master 

12. input hadoop-master's ip:8088 to browser hadoop cluster

13. run test.sh in hadoop-master container to test hadoop-cluser.

# Install JDK
sudo apt install openjdk-8-jre-headless
sudo apt install openjdk-8-jdk-headless

# Check java version
java -version

# Get hadoop
wget http://apache.mirror.digitalpacific.com.au/hadoop/common/hadoop-2.10.1/hadoop-2.10.1.tar.gz

# Extract
tar -xzvf ./hadoop-2.10.1.tar.gz
# Set JAVA_HOME
vi /etc/hadoop/hadoop-env.sh
#"export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64"

# Local Testing
mkdir input
cp etc/hadoop/* input/
bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.10.1.jar grep input output 'dfs[a-z.]+'
cat output/*

# Pseudo-distributed Mode
# Generate a keypair for ssh to localhost
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
# Add genereated pub key to authorized_keys
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# Edit configuration files
vi etc/hadoop/core-site.xml
vi etc/hadoop/hdfs-site.xml
vi etc/hadoop/mapred-site.xml
vi etc/hadoop/yarn-site.xml

# Format namenode
bin/hdfs namenode -format

# Start dfs
sbin/start-dfs.sh

# Check current java process
jps
# 5066 DataNode
# 5291 SecondaryNameNode
# 5531 Jps
# 4876 NameNode

# Use browser to access http://hostname:50070 to check the namenode status

bin/hdfs dfs -ls /
bin/hdfs dfs -mkdir /user
bin/hdfs dfs -mkdir /user/ubuntu

# Start yarn
sbin/start-yarn.sh
# Check yarn process
jps
# > 5766 ResourceManager
# 6263 Jps
# > 5961 NodeManager
# 5066 DataNode
# 5291 SecondaryNameNode
# 4876 NameNode

# Access http://hostname:8088 to check the cluster

bin/hdfs dfs -mkdir input
bin/hdfs dfs -put etc/hadoop/* input/
bin/hdfs dfs -ls input
bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.10.1.jar grep input output 'dfs[a-z.]+'
bin/hdfs dfs -cat output/*

# Build the test Jar
javac -cp $(~/hadoop-2.10.1/bin/hadoop classpath) Main.java Map.java Reduce.java
vi Manifest.txt
jar cfm Wordcount.jar Manifest.txt Main.class Map.class Reduce.class

hadoop jar ~/wordcount/Wordcount.jar /mapreduce/input /mapreduce/output

# Build YARN Queues
vi etc/hadoop/capacity-scheduler.xml
hadoop jar ~/wordcount/Wordcount.jar -D mapreduce.job.queuename=prod /mapreduce/input /mapreduce/output3

# Stop processes
sbin/stop-dfs.sh
sbin/stop-yarn.sh
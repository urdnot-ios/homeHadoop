#!/bin/bash
# chkconfig: - 99 10
#
#       /etc/rc.d/init.d/<servicename>
#
#       <description of the *service*>
#       <any general comments about this init script>
#
# <tags -- see below for tag definitions.  *Every line* from the top
#  of the file to the end of the tags section must begin with a #
#  character.  After the tags section, there should be a blank line.
#  This keeps normal comments in the rest of the file from being
#  mistaken for tags, should they happen to fit the pattern.>
#  sudo chkconfig --level 345 spark-master on

# Source function library.
export HADOOP_OPTS=-Djava.library.path=/opt/hadoop/lib
export JAVA_HOME=/lib/jvm/java-1.8.0-openjdk-1.8.0.102-1.b14.el7_2.x86_64/jre
export PATH=$PATH:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/opt/hadoop/bin:/opt/hadoop/sbin:/opt/spark/bin:/home/hdfs/.local/bin:/home/hdfs/bin
export HADOOP_HDFS_HOME=/opt/hadoop
export HADOOP_COMMON_HOME=/opt/hadoop
export SPARK_HOME=/opt/spark
DESC="spark master startup"
DAEMON="spark-master"

. /etc/init.d/functions

start() {
        echo -n "Starting spark master: "
        su - hdfs -c "$SPARK_HOME/sbin/start-master.sh --webui-port 8090"
        touch /var/lock/subsys/spark_master
        return 0
}

stop() {
        echo -n "Shutting down namenode: "
        su - hdfs -c "$SPARK_HOME/sbin/stop-master.sh"
        rm -f /var/lock/subsys/spark_master
        return 0
}

case "$1" in
    start)
          start
          ;;
    stop)
      stop
          ;;
    status)
        ;;
    restart)
          stop
          start
        ;;
    reload)

        ;;
    condrestart)
        #[ -f /var/lock/subsys/<service> ] && restart || :
        ;;
    *)
        echo "Usage: namenode {start|stop|status|reload|restart[|probe]"
        exit 1
        ;;
esac
exit $?
        

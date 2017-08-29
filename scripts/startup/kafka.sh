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

# Source function library.
. /etc/init.d/functions
export KAFKA_HOME=/opt/kafka
export DAEMON_NAME=kafka
# Check that networking is up.
#[ ${NETWORKING} = "no" ] && exit 0

export HADOOP_OPTS=-Djava.library.path=/opt/hadoop/lib
export JAVA_HOME=/lib/jvm/java-1.8.0-openjdk-1.8.0.102-1.b14.el7_2.x86_64/jre
export PATH=$PATH:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/opt/hadoop/bin:/opt/hadoop/sbin:/opt/spark/bin:/home/hdfs/.local/bin:/home/hdfs/bin:$KAFKA_HOME
export HADOOP_HDFS_HOME=/opt/hadoop
export HADOOP_COMMON_HOME=/opt/hadoop
export SPARK_HOME=/opt/spark
DESC="kafka startup"
DAEMON="kafka"

start() {
	echo "Starting $DAEMON";
	su - hdfs -c "$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties"
    touch /var/lock/subsys/kafka
    return 0
}

stop() {
	echo "Shutting down $DAEMON";
	pid=`ps ax | grep -i 'kafka.Kafka' | grep -v grep | awk '{print $1}'`
	if [ -n "$pid" ]
	then
		kill -9 $pid
	else
		echo "Kafka was not Running"
	fi
	rm -f /var/lock/subsys/kafka
    return 0
}

status() {
	pid=`ps ax | grep -i 'kafka.Kafka' | grep -v grep | awk '{print $1}'`
	if [ -n "$pid" ]
	then
	    echo "Kafka is Running as PID: $pid"
    else
	    echo "Kafka is not Running"
    fi
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
	    status
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
        echo "Usage: kafka {start|stop|status|reload|restart[|probe]"
        exit 1
        ;;
esac
exit $?

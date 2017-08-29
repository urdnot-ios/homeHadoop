#!/bin/sh
# kFreeBSD do not accept scripts as interpreters, using #!/bin/sh and sourcing.
if [ true != "$INIT_D_SCRIPT_SOURCED" ] ; then
    set "$0" "$@"; INIT_D_SCRIPT_SOURCED=true . /lib/init/init-d-script
fi
### BEGIN INIT INFO
# Provides:          skeleton
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Example initscript
# Description:       This file should be used to construct scripts to be
#                    placed in /etc/init.d.  This example start a
#                    single forking daemon capable of writing a pid
#                    file.  To get other behavoirs, implemend
#                    do_start(), do_stop() or other functions to
#                    override the defaults in /lib/init/init-d-script.
### END INIT INFO

# Author: Jeffrey Sewell 
# sudo chmod 755 /etc/init.d/hadoop 
# sudo update-rc.d hadoop defaults
# Please remove the "Author" lines above and replace them
# with your own name if you copy and modify this script.
#
# Some things that run always
touch /var/lock/hadoop
export HADOOP_CLASSPATH=/opt/hadoop/lib/*.jar
export HADOOP_HOME=/opt/hadoop
export PATH=$PATH:$HADOOP_HOME/bin
export PATH=$PATH:$HADOOP_HOME/sbin
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
export HADOOP_YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib"
export HADOOP_PREFIX=/opt/hadoop
export JAVA_HOME=/lib/jvm/java-1.8.0-openjdk-1.8.0.131-2.b11.el7.arm/jre
DESC="datanode and nodemanager startup"
DAEMON="hadoop-hdfs-datanode"

# Carry out specific functions when asked to by the system
case "$1" in
  start)
    su - hdfs -c "$HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start datanode"
    su - hdfs -c "$HADOOP_YARN_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start nodemanager"
    echo "Starting datanode and nodemanager"
    ;;
  stop)
    su - hdfs -c "$HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs stop datanode"
    su - hdfs -c "$HADOOP_YARN_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR stop nodemanager"
    rm /var/lock/hadoop
    echo "stopping"
    ;;
  *)
    echo "Usage: start|stop"
    exit 1
    ;;
esac

exit 0

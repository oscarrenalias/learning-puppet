#!/bin/sh
### BEGIN INIT INFO
# Provides:          jboss
# Required-Start:    $local_fs $remote_fs $network $syslog
# Required-Stop:     $local_fs $remote_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start/Stop JBoss AS v7.0.0
### END INIT INFO
#
#source some script files in order to set and export environmental variables
#as well as add the appropriate executables to $PATH

export JBOSS_HOME=/opt/jboss-as-7.1.1.Final
export PATH=$JBOSS_HOME/bin:$PATH

case "$1" in
    start)
        echo "Starting JBoss AS 7.1.1"
        start-stop-daemon --start --quiet --background --chuid jboss --exec ${JBOSS_HOME}/bin/standalone.sh
    ;;
    stop)
        echo "Stopping JBoss AS 7.1.1"
        start-stop-daemon --start --quiet --chuid jboss --exec ${JBOSS_HOME}/bin/jboss-cli.sh -- --connect command=:shutdown
    ;;
    restart)
        echo "Stopping JBoss AS 7.1.1"
        start-stop-daemon --start --quiet --chuid jboss --exec ${JBOSS_HOME}/bin/jboss-cli.sh -- --connect command=:shutdown

        echo "Starting JBoss AS 7.1.1"
        start-stop-daemon --start --quiet --background --chuid jboss --exec ${JBOSS_HOME}/bin/standalone.sh
    ;;
    *)
        echo "Usage: /etc/init.d/jboss {start|stop|restart}"
        exit 1
    ;;
esac

exit 0

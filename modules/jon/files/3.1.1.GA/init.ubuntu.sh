#!/bin/sh
### BEGIN INIT INFO
# Provides:          jon 
# Required-Start:    $local_fs $remote_fs $network $syslog
# Required-Stop:     $local_fs $remote_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start/Stop JBoss AS v7.0.0
### END INIT INFO
#
#source some script files in order to set and export environmental variables
#as well as add the appropriate executables to $PATH

export RHQ_SERVER_JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::") 
export JON_HOME="/opt/jon/jon-server-3.1.1.GA"

case "$1" in
    start)
        echo "Starting JON"
        start-stop-daemon --start --quiet --background --chuid jon --exec ${JON_HOME}/bin/rhq-server.sh start
    ;;
    stop)
        echo "Stopping JON"
        start-stop-daemon --start --quiet --chuid jon --exec ${JON_HOME}/bin/rhq-server.sh stop
    ;;
    restart)
        echo "Stopping JON"
        start-stop-daemon --start --quiet --chuid jon --exec ${JON_HOME}/bin/rhq-server.sh stop

        echo "Starting JON"
        start-stop-daemon --start --quiet --background --chuid jon --exec ${JON_HOME}/bin/rhq-server.sh start
    ;;
    status)
	${JON_HOME}/bin/rhq-server.sh status
    ;;
    *)
        echo "Usage: service jon {start|stop|restart}"
        exit 1
    ;;
esac

exit 0

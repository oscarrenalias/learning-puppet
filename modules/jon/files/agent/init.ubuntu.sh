#!/bin/sh
### BEGIN INIT INFO
# Provides:          rhq-agent
# Required-Start:    $local_fs $remote_fs $network $syslog
# Required-Stop:     $local_fs $remote_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start/Stop the JON/RHQ Agent
### END INIT INFO
#
#source some script files in order to set and export environmental variables
#as well as add the appropriate executables to $PATH

export RHQ_SERVER_JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::") 
export RHQ_AGENT_HOME="/opt/rhq-agent"

case "$1" in
    start)
        echo "Starting RHQ Agent"
        start-stop-daemon --start --quiet --background --chuid jboss --exec ${JON_HOME}/bin/rhq-agent.sh --daemon --config=${JON_HOME}/conf/agent-configuration.xml
    ;;
    stop)
        echo "Stopping RHQ Agent"
        start-stop-daemon --start --quiet --background --chuid jboss --exec ${JON_HOME}/bin/rhq-agent.sh --daemon --config=${JON_HOME}/conf/agent-configuration.xml
    ;;
    restart)
        echo "Stopping JON"
        start-stop-daemon --start --quiet --background --chuid jboss --exec ${JON_HOME}/bin/rhq-agent.sh --daemon --config=${JON_HOME}/conf/agent-configuration.xml

        echo "Starting JON"
        start-stop-daemon --start --quiet --background --chuid jboss --exec ${JON_HOME}/bin/rhq-agent.sh --daemon --config=${JON_HOME}/conf/agent-configuration.xml
    ;;
    *)
        echo "Usage: service jon {start|stop|restart}"
        exit 1
    ;;
esac

exit 0

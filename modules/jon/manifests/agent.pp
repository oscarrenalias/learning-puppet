class jon::agent($jonserver, $port = 7080) {
        common::download { "http://$jonserver:$port/agentupdate/download":
                target => "/tmp/rhq-agent.jar",
        }

        exec { "install-agent":
		path => ["/bin", "/usr/bin"],	# let's hope it's there...
                command => "java -jar /tmp/rhq-agent.jar --install=/opt",
                creates => "/opt/rhq-agent",
        }

	File { 
		owner => "jboss",
		group => "jboss"
	}

	# deploy the config file
	file { "agent-config":
		path => "/opt/rhq-agent/conf/agent-configuration.xml",
		content => template("jon/agent/agent-configuration.xml.erb"),
		require => Exec["install-agent"],
	}

	# and the logging settings
	file { "log4j-config":
		path => "/opt/rhq-agent/conf/log4j.xml",
		content => template("jon/agent/log4j.xml.erb"),
		require => Exec["install-agent"],
	}

	# copy the correct startup script
	case $operatingsystem {
		ubuntu: { $init_script = "init.ubuntu.sh" }
		default: { fail("Only Ubuntu systems are currently supported") }
	}

	# startup script
	file { "rhq-agent-startup":
		path => "/etc/init.d/rhq-agent",
		ensure => present,
		source => "puppet:///modules/jon/agent/$init_script",
		mode => 0777,
#		notify => Service["rhq-agent"],
	}

        file { "/opt/rhq-agent":
                ensure => "directory",
                require => Exec["install-agent"],
                recurse => true,
        }
}

# Static definition of a JON agent node, which can be applied to nodes; bear in mind that
# we're hardcoding here the hostname of our JON server but in a real environment it should probably
# be fetched from either a site.pp attribute or somewhere else...
class jon::agent::node {
        include java::openjdk7

	$jonserver = "ec2-54-246-21-76.eu-west-1.compute.amazonaws.com"

        class { 'jon::agent':
                jonserver => $jonserver
        }
}

#
# Handles installations of standalone JBoss servers
#
# TODO:
#   Support for domain installations
#   Move the JBoss path to a variable so that we can reuse it
class jboss($version = $title, $adminUser, $adminPassword) {
	common::download { "jboss-$version-download":
		url => "http://download.jboss.org/jbossas/7.1/jboss-as-$version/jboss-as-$version.tar.gz",
		target => "/tmp/jboss-as-$version.tar.gz",
		notify => Common::Untar["jboss-untar-$version"]
	}

	common::untar { "jboss-untar-$version":
		source => "/tmp/jboss-as-$version.tar.gz",
		target => "/opt",
		ifNotExists => "/opt/jboss-as-$version",
		notify => File["fix-ownership-$version"]
	}

	# create the jboss system user
	user { "jboss":
		ensure => present,
		gid => "jboss",
		require => Group["jboss"]
	}

	group { "jboss":
		ensure => present
	}

	# and fix the ownership of the folder in /opt
	file { "fix-ownership-$version":
		path => "/opt/jboss-as-$version",
		owner => "jboss",
		group => "jboss",
		recurse => true,
		require => User["jboss"]
	}

	# copy the correct startup script
	case $operatingsystem {
		ubuntu: { $init_script = "init.ubuntu.sh" }
		default: { fail("Only Ubuntu systems are currently supported") }
	}

	# set up the service startup file
	file { "init-script-$version":
		path => "/etc/init.d/jboss",
		source => "puppet:///modules/jboss/$version/$init_script",
		require => Common::Untar["jboss-untar-$version"],
		mode => 0777,
		notify => Service["jboss"]
	}

	# and the standalone configuration file with our own settings
	file { "standalone-config-$version":
		path => "/opt/jboss-as-$version/bin/standalone.conf",
		content => template("jboss/standalone.conf.erb"),
		owner => "jboss",
		group => "jboss",
		mode => 0644,
		require => File["init-script-$version"],
		notify => [Service["jboss"], Jboss::Adduser["adduser-$adminUser"]]
	}

	service { "jboss": 
		ensure => running,
		hasstatus => false,
		hasrestart => true,
		# TODO: this is kind of crude...
		pattern => "java.*-server"
	}

	# create the default admin user
	jboss::adduser { "adduser-$adminUser":
		name => $adminUser,
		password => $adminPassword,
		type => "management",
		jbosspath => "/opt/jboss-as-$version"
	}
}

# Non-parameterized class so that we can assign it to nodes
class jboss::jboss_node {
	if empty($jboss_version) == true {
		fail("Please define variable jboss_version for the node")
	}
	else {  
		include java::openjdk7
		
		class { 'jboss':
			version => $jboss_version,
			adminUser => "admin",
			adminPassword => "password"
		}
	}
}

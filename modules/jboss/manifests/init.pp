class jboss($version = $title) {
	common::download { "jboss-$version-download":
		url => "http://download.jboss.org/jbossas/7.1/jboss-as-$version/jboss-as-$version.tar.gz",
		target => "/tmp/jboss-as-$version.tar.gz"
	}

	common::untar { "jboss-untar-$version":
		source => "/tmp/jboss-as-$version.tar.gz",
		target => "/opt",
		require => Common::Download["jboss-$version-download"]
	}

	# create the jboss user
	user { "jboss":
		ensure => present,
		require => Common::Untar["jboss-untar-$version"]
	}

	# and fix the ownership of the folder in /opt
	file { "/opt/jboss-as-$version":
		owner => "jboss",
		recurse => true,
		require => User["jboss"]
	}

	# copy the correct startup script
	case $operatingsystem {
		ubuntu: { $init_script = "init.ubuntu.sh" }
		default: { fail("Only Ubuntu systems are currently supported") }
	}

	# set up the service startup file
	file { "/etc/init.d/jboss-$version":
		source => "puppet:///modules/jboss/$init_script",
		require => Common::Untar["jboss-untar-$version"],
		mode => 0777,
	}

	service { "jboss-$version": 
		ensure => running
	}

	File["/etc/init.d/jboss-$version"] -> Service["jboss-$version"]
}
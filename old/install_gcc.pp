case $operatingsystem {
	centos, redhat: {
		package { "gcc":
			ensure => installed
		}
	}
	debian, ubuntu: {
		package { "build-essential":
			ensure => installed
		}
		notify { "build-essential successfully installed":
			require => Package["build-essential"]
		}
		package { "gcc":
			ensure => installed
		}
	}
}


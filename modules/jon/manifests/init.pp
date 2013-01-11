class jon($version = $title) {
	class { "postgresql::server": }

	postgresql::db { "rhq":
		user => "rhqadmin",
		password => "password",
		grant => [ "all" ],
	}

	common::download { "jon-server":
		url => "https://s3-eu-west-1.amazonaws.com/pq-files/jon/$version/jon-server-$version.zip",
		target => "/tmp/jon-server-$version.zip",
		notify => File["jon-home"]
	}

	file { "jon-home":
		path => "/opt/jon",
		ensure => "directory",
		notify => Common::Unzip["jon-server-zip"]
	}

	user { "jon":
		ensure => present
	}

	group { "jon":
		ensure => present
	}

        # copy the correct startup script
	case $operatingsystem {
		ubuntu: { $init_script = "init.ubuntu.sh" }
		default: { fail("Only Ubuntu systems are currently supported") }
	}

	# set up the service startup file
	file { "jon-init-script-$version":
		path => "/etc/init.d/jon",
		source => "puppet:///modules/jon/$version/$init_script",
		mode => 0777,
	}

	common::unzip { "jon-server-zip":
		source => "/tmp/jon-server-$version.zip",
		ifNotExists => "/opt/jon/jon-server-$version",
		target => "/opt/jon",
		notify => File["/opt/jon/jon-server-$version"],
	}

	file { "/opt/jon/jon-server-$version":
		owner => "jon",
		group => "jon",
		recurse => true,
		require => [User["jon"], Group["jon"]]
	}

	service { "jon":
		ensure => running
	}

}

class jon::server {
	if empty($jon_version) == true {
		fail("Please definev note attribute jon_version for the node")
	}

	include java::openjdk7

	class { 'jon':
		version => $jon_version
	}
}

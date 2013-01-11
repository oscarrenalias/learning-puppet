class jon($version = $title) {
	class { "postgresql::server": }

	postgresql::db { "rhq":
		user => "rhqadmin",
		password => "password",
		grant => [ "all" ],
	}

	common::download { "jon-server":
		url => "https://s3-eu-west-1.amazonaws.com/pq-files/jon/$version/jon-server-$version.zip",
		target => "/tmp/jon-server-$version.gzip",
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

	common::unzip { "jon-server-zip":
		source => "/tmp/jon-server-$version.zip",
		ifNotExists => "/opt/jon",
		target => "/opt/jon",
		notify => File["/opt/jon/jon-server-$version"],
	}

	file { "/opt/jon/jon-server-$version":
		owner => "jon",
		group => "jon",
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

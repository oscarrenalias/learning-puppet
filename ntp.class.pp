# Same as ntp.pp but now we group all the NTP properties in a Puppet class
class ntp {
	package { "ntp":
		ensure => present,
		before => File["ntp.conf"],
	}

	notify { "NTP package installed":
		require => Package["ntp"]
	}

	# Define which config file we need
	$conf_file = $operatingsystem ? {
		redhat => "ntp.conf.el",
		/(?i)(ubuntu|debian)/ => "ntp.conf.debian"
	}

	file { "ntp.conf":
		ensure => file,
		path => "/etc/ntp.conf",
		mode => 633,
		source => "/home/ubuntu/learning-puppet/${conf_file}"
	}

	service { "ntp":
		ensure => running,
		enable => true,
		hasrestart => true,
		hasstatus => true,
		subscribe => File["ntp.conf"]
	}
}

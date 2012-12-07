# Same as ntp.pp but now we group all the NTP properties in a Puppet class
# Should be linked/moved from ~/.puppet/modules/ntp/manifests or /etc/puppetlabs/puppet/modules
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
		redhat => "puppet:///modules/ntp/ntp.conf.el",
		/(?i)(ubuntu|debian)/ => "puppet:///modules/ntp/ntp.conf.debian"
	}

	file { "ntp.conf":
		ensure => file,
		path => "/etc/ntp.conf",
		mode => 633,
		source => "${conf_file}"
	}

	service { "ntp":
		ensure => running,
		enable => true,
		hasrestart => true,
		hasstatus => true,
		subscribe => File["ntp.conf"]
	}
}

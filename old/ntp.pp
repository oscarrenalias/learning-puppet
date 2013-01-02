package { "ntp":
	ensure => present,
	before => File["/etc/ntp.conf"],
}

notify { "NTP package installed":
	require => Package["ntp"]
}

# Define which config file we need
$conf_file = $operatingsystem ? {
	redhat => "ntp.conf.el",
	/(?i)(ubuntu|debian)/ => "ntp.conf.debian"
}

file { "/etc/ntp.conf":
	ensure => file,
	mode => 633,
	source => "/home/ubuntu/learning-puppet/${conf_file}"
}

service { "ntp":
	ensure => running,
	enable => true,
	hasrestart => true,
	hasstatus => true,
	subscribe => File["/etc/ntp.conf"]
}

package { "apache2":
	ensure => installed
}

service { "apache2":
	name => "apache2",
	ensure => "running"
}	

class java ($version) {
	if empty($version) == true {
		fail("You must specific a valid Java version")
	}
	else {
		package { "$version":
			ensure => installed
		}
	}
}

class java::openjdk7 {
	class { "java":
		version => "openjdk-7-jdk"
	}
}

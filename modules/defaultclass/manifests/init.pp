class defaultclass {
	include common::wget

	# additional packages
	package { "git":
		ensure => installed
	}

        package { "unzip":
          ensure => installed
        }
}

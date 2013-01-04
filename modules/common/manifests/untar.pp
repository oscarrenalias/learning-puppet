define common::untar($source = $title, $target, $ifNotExists) {
	exec { "untar-$source-$target":
		command => "tar zxvf $source -C $target",
		path => [ "/bin", "/usr/bin", "/usr/local/bin" ],
		require => File["untar-target-$target"],
		creates => $ifNotExists
	}

	file { "untar-target-$target":
	        path => $target,
		ensure => directory
	}
}

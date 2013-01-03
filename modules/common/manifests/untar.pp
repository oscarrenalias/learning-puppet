define common::untar($source = $title, $target, $ifNotExists) {
	exec { "untar-$source-$target":
		command => "tar zxvf $source -C $target",
		path => [ "/bin", "/usr/bin", "/usr/local/bin" ],
		require => File["$target"],
		creates => $ifNotExists
	}

	file { "$target": 
		ensure => directory
	}
}

define common::untar($source = $title, $target) {
	exec { "untar-$source-$target":
		command => "tar zxvf $source -C $target",
		path => [ "/bin", "/usr/bin", "/usr/local/bin" ],
		require => File["$target"],
		creates => $target
	}

	file { "$target": 
		ensure => directory
	}

	notify { "$source successfully unpacked to target $target":
		require => Exec["untar-$source-$target"]
	}
}
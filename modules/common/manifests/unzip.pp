define common::unzip($source = $title, $target, $ifNotExists) {
	package { "unzip":
		ensure => installed,
		notify => Exec["unzip-$source-$target"]
	}

	exec { "unzip-$source-$target":
		command => "unzip $source -d $target",
		path => [ "/bin", "/usr/bin", "/usr/local/bin" ],
		creates => $ifNotExists,
	}
}

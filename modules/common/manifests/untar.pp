define common::untar($source = $title, $target) {
	exec { "tar zxvf $source -C $target":
		creates => $target,
		path => [ "/bin", "/usr/bin", "/usr/local/bin" ]
	}
}
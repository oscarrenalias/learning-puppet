define common::download($url = $title, $target) {
	exec { "wget $url -O $target":
		creates => $target,
		require => Package["wget"],
		path => [ "/bin", "/usr/bin", "/usr/local/bin" ]
	}

	package { "wget": }
}
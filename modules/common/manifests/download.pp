define common::download($url = $title, $target) {
	include common::wget

	exec { "wget $url -O $target":
		creates => $target,
		require => Package["wget"],
		path => [ "/bin", "/usr/bin", "/usr/local/bin" ]
	}
}

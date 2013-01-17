define common::unzip($source = $title, $target, $ifNotExists, $owner = 'UNDEF', $group = 'UNDEF') {

	exec { "unzip-$source-$target":
		command => "unzip $source -d $target",
		path => [ "/bin", "/usr/bin", "/usr/local/bin" ],
		creates => $ifNotExists,
	}

	if($owner != 'UNDEF') or ($group != 'UNDEF') {
		if($owner != 'UNDEF') and ($group == 'UNDEF') { $param = $owner }
		if($group != 'UNDEF') and ($owner == 'UNDEF') { $param = ":$group" }
		if($group != 'UNDEF') and ($owner != 'UNDEF') { $param = "$owner:$group" }
		
		exec { "fix-target-permissions-$target":
			command => "chown -R $param $target",
			path => [ "/bin/", "/usr/bin" ],
			subscribe => Exec["unzip-$source-$target"],
		}
	}
}

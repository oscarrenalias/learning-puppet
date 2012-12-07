file { '/etc/ssh/sshd_config':
      ensure => file,
      mode   => 600,
      source => '/home/ubuntu/learning-puppet/sshd_config',
}

service { 'ssh':
	ensure => running,
	enable => true,
	subscribe => File['/etc/ssh/sshd_config']
}

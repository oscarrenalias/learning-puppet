#
# Handles installations of standalone JBoss servers
#

# Defines some sane defaults for the class
class jboss::params {
	$adminUser = "admin"
	$adminPassword = "password"
	$standaloneConf = template("jboss/standalone.conf.erb")
	$standaloneXml = template("jboss/standalone.xml.erb")
	$user = "jboss"
	$group = "jboss"
        $enableService = true
}	

# TODO:
#   Support for domain installations
#   Move the JBoss path to a variable so that we can reuse it
class jboss(
	$version = $title, 
	$adminUser = $jboss::params::adminUser, 
	$adminPassword = $jboss::params::adminPassword,
	$standaloneConf = $jboss::params::standaloneConf,
	$standaloneXml = $jboss::params::standaloneXml,
	$user = $jboss::params::user,
	$group = $jboss::params::group,
        $enableService = $jboss::params::enableService
) inherits jboss::params {

        $jbosshome = "/opt/jboss-as-$version"

	common::download { "jboss-$version-download":
		#url => "http://download.jboss.org/jbossas/7.1/jboss-as-$version/jboss-as-$version.tar.gz",
                url => "https://s3-eu-west-1.amazonaws.com/pq-files/jboss-as/$version/jboss-as-$version.tar.gz",
		target => "/tmp/jboss-as-$version.tar.gz",
		notify => Common::Untar["jboss-untar-$version"]
	}

	common::untar { "jboss-untar-$version":
		source => "/tmp/jboss-as-$version.tar.gz",
		target => "/opt",
		ifNotExists => "$jbosshome",
		notify => File["fix-ownership-$version"]
	}

	# create the jboss system user
	user { "jboss":
		name => $user,
		ensure => present,
		gid => $group,
		require => Group["jboss"]
	}

	group { "jboss":
		name => $group,
		ensure => present
	}

	# and fix the ownership of the folder in /opt
	file { "fix-ownership-$version":
		path => "$jbosshome",
		owner => $user,
		group => $group,
		recurse => true,
		require => User["jboss"]
	}

	# copy the correct startup script
	case $operatingsystem {
		ubuntu: {
                  $init_script = "init.ubuntu.sh"
                  file { "jboss-ubuntu-defaults":
                    path => "/etc/default/jboss-as",
                    owner => $user,
                    group => $group,
                    content => template("jboss/$version/ubuntu-defaults-jboss-as.erb"),
                    ensure => "present",
                  }
                }
		default: { fail("Only Ubuntu systems are currently supported") }
	}

	# set up the service startup file
	file { "init-script-$version":
		path => "/etc/init.d/jboss",
		source => "puppet:///modules/jboss/$version/$init_script",
		require => Common::Untar["jboss-untar-$version"],
		mode => 0777,
		notify => Service["jboss"]
	}

	# and the standalone configuration files with our own settings
	File { group => $group, owner => $user }

	file { "standalone-config-$version":
		path => "$jbosshome/bin/standalone.conf",
		content => $standaloneConf,
		require => File["init-script-$version"],
		mode => 0644,
		notify => [Service["jboss"], Jboss::Adduser["adduser-$adminUser"]]
	}
	file { "standalone-xml-config":
		path => "$jbosshome/standalone/configuration/standalone.xml",
		content => $standaloneXml,
		mode => 0644,
		notify => Service["jboss"],
	}

	service { "jboss":
                name => "jboss",
		ensure => running,
		hasstatus => true,
		hasrestart => true,
                enable => true
	}

	# create the default admin user
	jboss::adduser { "adduser-$adminUser":
		name => $adminUser,
		password => $adminPassword,
		type => "management",
		jbosspath => "$jbosshome"
	}
}

# Non-parameterized class so that we can assign it to nodes
class jboss::jboss_node {
	if empty($jboss_version) == true {
		fail("Please define variable jboss_version for the node")
	}
	else {  
		include java::openjdk7
		
		class { 'jboss':
			version => $jboss_version,
		}
	}
}

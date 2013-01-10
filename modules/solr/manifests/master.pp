#
# Parameters:
#	version: version string of Solr to deploy
#	config: initial configuration to use; taken from the files/configs/ folder
#	jbossroot: root location of JBoss
#

class solr::master($version, $config, $jbossroot) {
	common::download { "solr-package":
		url => "http://www.nic.funet.fi/pub/mirrors/apache.org/lucene/solr/$version/apache-solr-$version.tgz",
		alias => "solr-package",
		target => "/tmp/apache-solr-$version.tar.gz",
		notify => Common::Untar["untar-solr-$version"]
	}

	common::untar { "untar-solr-$version":
		source => "/tmp/apache-solr-$version.tar.gz",
		# This is kind of crude, since we have to have a unique name for this...
		target => "/opt/solr",
		ifNotExists => "/opt/solr/apache-solr-$version",
		notify => Jboss::Cli::Sysproperty_add["solr-home-property"],
	}

	# configure the Solr home *before* we deploy the WAR
	jboss::cli::sysproperty_add { "solr-home-property":
		user => "admin",
		password => "password",
		jbossroot => $jbossroot,
		name => "solr.solr.home",
		value => "/opt/solr/home",
		notify => [Jboss::Deploy["jboss-deploy-solr-$version"],Solr::Init_home["solr-home"]]
	} 

	# put the Solr WAR in its right place
	jboss::deploy { "jboss-deploy-solr-$version":
		source => "/opt/solr/apache-solr-$version/dist/apache-solr-$version.war",
		target => "solr.war",
		jbossroot => $jbossroot,
		replace => true
	}

	solr::init_home { "solr-home":
		solrhome => "/opt/solr/home",
		version => $version,
		config => $config,
		replace => false,
	}
}

#
# Initializes a Solr home with a default set of configuration files
#
define solr::init_home($solrhome, $version, $config, replace = false) {
	# set up the Solr home if it doesn't exist
	debug("solr::init_home: solrhome = $solrhome, config = $config, replace = $replace")

	file { "solr-home-$solrhome-$config-$replace":
	     path => $solrhome,
	     source => "puppet:///modules/solr/configs/$version/$config",
	     recurse => true,
	     group => "jboss",
	     owner => "jboss",
	     ensure => directory,
	     replace => $replace,
	}
}

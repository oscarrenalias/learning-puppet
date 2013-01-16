#
# Parameters:
#	version: version string of Solr to deploy
#	config: initial configuration to use; taken from the files/configs/ folder
#	jbossroot: root location of JBoss
#

class solr::master(
	$version, 
	$config, 
	$jbossroot = $solr::params::jbossroot,
	$solrroot = $solr::params::solrroot,
	$solrhome = $solr::params::solrhome
) inherits solr::params {

	Class["solr::master"] ~> Service["jboss"]

	common::download { "solr-package":
		url => "http://www.nic.funet.fi/pub/mirrors/apache.org/lucene/solr/$version/apache-solr-$version.tgz",
		alias => "solr-package",
		target => "/tmp/apache-solr-$version.tar.gz",
		notify => Common::Untar["untar-solr-$version"]
	}

	common::untar { "untar-solr-$version":
		source => "/tmp/apache-solr-$version.tar.gz",
		# This is kind of crude, since we have to have a unique name for this...
		target => $solrroot,
		ifNotExists => "$solrhome/apache-solr-$version",
		#notify => Jboss::Cli::Sysproperty_add["solr-home-property"],
		notify => Jboss::Deploy["jboss-deploy-solr-$version"]
	}

	# configure the Solr home *before* we deploy the WAR
	jboss::cli::sysproperty_add { "solr-home-property":
		user => "admin",
		password => "password",
		jbossroot => $jbossroot,
		name => "solr.solr.home",
		value => "$solrhome",
		require => Jboss::Deploy["jboss-deploy-solr-$version"],
		#notify => [Jboss::Deploy["jboss-deploy-solr-$version"],Solr::Tools::Init_home["solr-home"]]
	} 

	# put the Solr WAR in its right place and tell the JBoss service to restart
	jboss::deploy { "jboss-deploy-solr-$version":
		source => "$solrroot/apache-solr-$version/dist/apache-solr-$version.war",
		target => "solr.war",
		jbossroot => $jbossroot,
		replace => true,
		#notify => Service["jboss"]
	}

	solr::tools::init_home { "solr-home":
		solrhome => "$solrhome",
		version => $version,
		config => $config,
		replace => false,
	}
}

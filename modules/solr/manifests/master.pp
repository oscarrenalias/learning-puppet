class solr::master($version, $jbossroot) {
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
		notify => Jboss::Deploy["jboss-deploy-solr-$version"],
	}

	# put the Solr WAR in its right place
	jboss::deploy { "jboss-deploy-solr-$version":
		source => "/opt/solr/apache-solr-$version/dist/apache-solr-4.0.0.war",
		target => "solr.war",
		jbossroot => $jbossroot,
		replace => true
	}
}
 
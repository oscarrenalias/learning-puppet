class solr::slave($version, $master_address = undef) {
	common::download { "solr-package":
		url => "http://www.nic.funet.fi/pub/mirrors/apache.org/lucene/solr/${version}/apache-solr-${version}.tgz",
		alias => "solr-package",
		target => "/tmp/apache-solr-${version}.tar.gz"
	}

	common::untar { "/tmp/apache-solr-${version}.tar.gz":
		target => "/tmp",
		require => Common::Download["solr-package"]
	}
}
class solr::params {
	$jbossroot = "/opt/jboss-as-7.1.1.Final"
	$solrroot = "/opt/solr"
	$solrhome = "$solrroot/home"
}

class solr::solr_master {
	if empty($solr_version) {
        	 fail("Please define variables solr_version and jboss_version for the node first")
      	}

	require java::openjdk7
	require jboss::jboss_node

	class { "solr::master":
		version => $solr_version,
		config => "simple",
        }
}

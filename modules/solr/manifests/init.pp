class solr::solr_master {
      if (empty($solr_version) == true) or (empty($jboss_version) == true) {
      	 fail("Please define variables solr_version and jboss_version for the node first")
      }
      else {
      	   class { 'solr::master':
	   	 version => $solr_version,
		 jbossroot => "/opt/jboss-as-$jboss_version"
	  }	 
      }
}
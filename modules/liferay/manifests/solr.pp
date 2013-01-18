#
# Installs the Liferay solr-web plugin
#
class liferay::solr(
  $jbosshome = $liferay::params::jbosshome,
  $version = $liferay::params::version
  #$solrserver
) inherits liferay::params {

  # TODO: we should probably not repeat this across manifests
  $s3_server = "https://s3-eu-west-1.amazonaws.com"
  $s3_repo = "$s3_server/pq-files/liferay/$version"

  common::download { "liferay-solr-pkg":
    url => "$s3_repo/solr-web-$version.war",
    target => "/tmp/solr-web-$version.war",
    notify => Liferay::Hotdeploy["liferay-solr-hotdeploy"],
  }       

  liferay::hotdeploy { "liferay-solr-hotdeploy":
    source => "/tmp/solr-web-$version.war",
    package => "solr-web.war",
    liferayhome => "/opt/liferay",
    #require => Jboss::Cli::Sysproperty_add["liferay-solr-property"],
    jbosshome => $jbosshome,
  }

  #jboss::cli::sysproperty_add { "liferay-solr-property":
  #  user => "admin",
  #  password => "password",
  #  name => "liferay.solr.server",
  #  value => $solrserver,
  #  jbossroot => $jbosshome,
  #  timeout => 600,
  #}
}

#
# Initializes a Solr home with a default set of configuration files
#
define solr::tools::init_home($solrhome, $version, $config, replace = false) {
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

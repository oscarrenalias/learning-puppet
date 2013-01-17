class liferay(
	$instance_name = $title, 
	$version = $liferay::params::version, 
	$mysqldriver = $liferay::params::mysqldriver, 
	$jbosshome = $liferay::params::jbosshome,
	$liferayhome = $liferay::params::liferayhome,
) inherits liferay::params {

	$s3_server = "https://s3-eu-west-1.amazonaws.com"
	$s3_repo = "$s3_server/pq-files/liferay/$version"
	$mysqldrivername = "mysql-connector-java-$mysqldriver-bin.jar"

        if($version == 'UNDEF') {
          fail("Liferay version number required")
        }

	file { [ "$jbosshome/modules", "$jbosshome/modules/com", "$jbosshome/modules/com/liferay", 
		 "$jbosshome/modules/com/liferay/portal/" ]:
		ensure => directory,
		owner => "jboss",
		before => Common::Download["liferay-download-$version"],
	}

	common::download { "liferay-download-$version":
		url => "$s3_repo/liferay-portal-$version.war",
		target => "/tmp/liferay-portal-$version.war",
		notify => Common::Download["liferay-deps-download-$version"],
	}

	common::download { "liferay-deps-download-$version":
		url => "$s3_repo/liferay-portal-dependencies-$version.tar.gz",
		target => "/tmp/liferay-portal-dependencies-$version.tar.gz",
		notify => Common::Untar["liferay-dependencies-untar-$version"],
	}

	mysql::db { "liferay":
               	user => "liferay",
               	password => "liferay",
               	host => "localhost",
               	grant => [ "all" ],
		require => Common::Untar["liferay-dependencies-untar-$version"],
        }

	# install the dependencies first - we can have tar to unpack them in the right place. It's a
	# good idea if the dependencies package already includes the MySQL driver
	common::untar { "liferay-dependencies-untar-$version":
		source => "/tmp/liferay-portal-dependencies-$version.tar.gz",
		target => "$jbosshome/modules/com/liferay/portal/main",
		ifNotExists => "$jbosshome/modules/com/liferay/portal/main/portal-service.jar",
		notify => File["liferay-jboss-module.xml"],
	}

	file { "liferay-jboss-module.xml":
		path => "$jbosshome/modules/com/liferay/portal/main/module.xml",
		content => template("liferay/module.xml.erb"),
		ensure => present,
		owner => "jboss",
		notify => Jboss::Deploy["liferay-deploy-$version"],
	}

	# deploy the WAR as the root application, and explode it
	jboss::deploy { "liferay-deploy-$version":
		source => "/tmp/liferay-portal-$version.war",
		target => "liferay-portal-$version.war",
		jbossroot => $jbosshome,
		asroot => true,
	}

	# Liferay home
	file { "liferay-home":
		path => "$liferayhome",
		owner => "jboss",
		group => "jboss",
		ensure => "directory",
		replace => false
	}

        file { "liferay-home-deploy":
          path => "$liferaydeploy",
          owner => "jboss",
          group => "jboss",
          ensure => "directory",
          replace => false,
          require => File["liferay-home"],
        }

	# deploy our customized config file
	file { "liferay-portal-ext":
		path => "$jbosshome/standalone/deployments/ROOT.war/WEB-INF/classes/portal-ext.properties",
		ensure => "present",
		content => template("liferay/portal-ext.properties.erb"),
		replace => true,
		require => Jboss::Deploy["liferay-deploy-$version"],
		owner => "jboss",
	}

	# remove eclipselink.jar as per the instructions
	file { "remove-eclipselink":
		path => "$jbosshome/standalone/deployments/ROOT.war/WEB-INF/lib/eclipselink.jar",
		ensure => "absent",
		require => Jboss::Deploy["liferay-deploy-$version"],
	}
}

class liferay::liferay_node {
	if empty($liferay_version) == true {
		fail("Please define node attribute liferay_version for this node or group")
	}

	# MySQL dependency
	class { 'mysql::server': 
		config_hash => { 
			'root_password' => 'password',
			'etc_root_password' => true
		},
	}

	require java::openjdk7

	# Jboss dependency with Liferay as well as the Liferay solr-web plugin
	class { 'jboss':
		version => "7.1.1.Final",
		standaloneXml => template("liferay/jboss-standalone.xml.erb"),
	} -> class { "liferay":
		version => $liferay_version,
		mysqldriver => "5.1.22",
		instance_name => "test-instance",
		jbosshome => "/opt/jboss-as-7.1.1.Final",
	} -> class { "liferay::solr":
          version => $liferay_version,
          jbosshome => "/opt/jboss-as-7.1.1.Final",
          solrserver => "http://ec2-46-51-141-11.eu-west-1.compute.amazonaws.com:8080/solr",
        } -> jboss::force_restart { "force-jboss-liferay-restart":
          notify => Service["jboss"]
        }
        # This last line is kind of brutal, but can't think of another way to tell JBoss that it should reload itself
        # so that it can load some new JAR files deployed as a module by the Liferay manifest...
}

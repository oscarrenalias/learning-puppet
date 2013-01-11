

class liferay($instance_name = $title, $version, $mysqldriver, $jbosshome) {

	class { 'mysql::server': 
		config_hash => { 'root_password' => 'password' }
	}

	mysql::db { "liferay":
		user => "liferay",
		password => "liferay",
		host => "localhost",
		grant => [ "all" ]
	}
		
	$s3_server = "https://s3-eu-west-1.amazonaws.com"
	$s3_repo = "$s3_server/pq-files/liferay/$version"
	$mysqldrivername = "mysql-connector-java-$mysqldriver-bin.jar"

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
#		notify => [Common::Download["mysql-connector-$mysqldriver"], Common::Untar["liferay-dependencies-untar-$version"]],
		notify => Common::Untar["liferay-dependencies-untar-$version"],
	}

	# install the dependencies first - we can have tar to unpack them in the right place. It's a
	# good idea if the dependencies package already includes the MySQL driver
	common::untar { "liferay-dependencies-untar-$version":
		source => "/tmp/liferay-portal-dependencies-$version.tar.gz",
		target => "$jbosshome/modules/com/liferay/portal/main",
		ifNotExists => "$jbosshome/modules/com/liferay/portal/main/portal-service.jar",
		notify => [File["liferay-jboss-module.xml"], Jboss::Deploy["liferay-deploy-$version"]],
	}

	file { "liferay-jboss-module.xml":
		path => "$jbosshome/modules/com/liferay/portal/main/module.xml",
		content => template("liferay/module.xml.erb"),
		ensure => present,
		owner => "jboss",
	}

	# configuration files customized for Liferay
	file { "$jbosshome/standalone/configuration/standalone.xml":
		content => template("liferay/jboss-standalone.xml.erb"),
		ensure => present,
		replace => true,
	}

	# deploy the WAR as the root application, and explode it
	jboss::deploy { "liferay-deploy-$version":
		source => "/tmp/liferay-portal-$version.war",
		target => "liferay-portal-$version.war",
		jbossroot => $jbosshome,
		asroot => true,
		notify => File["remove-eclipselink"]
	}

	# Lifereay home
	file { "/opt/liferay":
		owner => "jboss",
		group => "jboss",
		ensure => "directory",
		replace => false
	}

	# deploy our customized config file
	file { "liferay-portal-ext":
		path => "$jbosshome/standalone/deployments/ROOT.war/WEB-INF/classes/portal-ext.properties",
		ensure => "present",
		content => template("liferay/portal-ext.properties.erb"),
		replace => true,
	}

	# remove eclipselink.jar as per the instructions
	file { "remove-eclipselink":
		path => "$jbosshome/standalone/deployments/ROOT.war/WEB-INF/lib/eclipselink.jar",
		ensure => "absent",
	}
}

class liferay::liferay_node {
	if empty($liferay_version) == true {
		fail("Please define node attribute liferay_version for this node or group")
	}

	class { "liferay":
		version => $liferay_version,
		mysqldriver => "5.1.22",
		instance_name => "test-instance",
		jbosshome => "/opt/jboss-as-7.1.1.Final",
	}
}

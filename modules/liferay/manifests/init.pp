

class liferay($instance_name = $title, $version, $mysqldriver, $jbosshome) {
	package { "mysql-server":
		ensure => installed
	}

	service { "mysql":
		ensure => running
	}

	$s3_server = "https://s3-eu-west-1.amazonaws.com"
	$s3_repo = "$s3_server/pq-files/liferay/$version"

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

	# including the MySQL JDBC driver
#	common::download { "mysql-connector-$mysqldriver":
#		url => "$s3_server/mysql-connector-java/$version/mysql-connector-java-$version.jar",
#		target => "$jbosshome/modules/com/liferay/portal/main",
#	}
		
	# install the dependencies first - we can have tar to unpack them in the right place
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
#	file { "liferay-custom-standalone.conf":
#		path => "$jbosshome/bin/standalone.conf",
#		content => template("liferay/jboss-standalone.conf.erb"),
#		ensure => present,
#		replace => true,
#	}

	# deploy the WAR
	jboss::deploy { "liferay-deploy-$version":
		source => "/tmp/liferay-portal-$version.war",
		target => "liferay-portal-$version.war",
		jbossroot => $jbosshome,
	}

	# we assume that JBoss is running in auto-deploy mode so the WAR will be deployed automatically

}

class liferay::liferay_node {
	if empty($liferay_version) == true {
		fail("Please define node attribute liferay_version for this node or group")
	}

	class { "liferay":
		version => "6.1.1-ce-ga2",
		mysqldriver => "5.1.22",
		instance_name => "test-instance",
		jbosshome => "/opt/jboss-as-7.1.1.Final",
	}
}

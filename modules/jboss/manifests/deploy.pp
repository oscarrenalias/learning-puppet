# Function that deploys a WAR file from the source folder into JBoss's standalone.
# It assumes that JBoss is configured in autodeploy mode.
define jboss::deploy($source = $title, $target, $jbossroot, $asroot = false, $replace = true) {
	File { owner => "jboss", group => "jboss" }

	if($asroot == true) {
		file { "jboss-deploy-root-exploded-$source":
			path => "$jbossroot/standalone/deployments/ROOT.war",
			replace => $replace,
			ensure => "directory",
			notify =>  Common::Unzip["unzip-package-$source"],
		}

		common::unzip { "unzip-package-$source":
			source => $source,
			target => "$jbossroot/standalone/deployments/ROOT.war",
			ifNotExists => "$jbossroot/standalone/deployments/ROOT.war/WEB-INF",
			notify => File["jboss-root-deployment-file"],		
		}
		
		file { "jboss-root-deployment-file":
			path => "$jbossroot/standalone/deployments/ROOT.war.dodeploy",
			ensure => exists,
		}
	}
	else {
       		file { "jboss-deploy-$source":
       	    		replace => $replace, # force to be replaced by default if already exists
	    		mode => 0644,
	    		source => $source,
	    		path => "$jbossroot/standalone/deployments/$target",
       		}
		file { "jboss-deploy-$source-dodeploy":
			path => "$jbossroot/standalone/deployments/$target.dodeploy",
			ensure => exists,
			require => File["jboss-deploy-$source"],
		}	
	}
}

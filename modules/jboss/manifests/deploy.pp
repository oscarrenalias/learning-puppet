# Function that deploys a WAR file from the source folder into JBoss's standalone.
# It assumes that JBoss is configured in autodeploy mode.
define jboss::deploy($source = $title, $target, $jbossroot, $replace = true) {
       file { "jboss-deploy-$source":
       	    replace => $replace, # force to be replaced by default if already exists
	    mode => 0644,
	    source => $source,
	    path => "$jbossroot/standalone/deployments/$target",
       }
}
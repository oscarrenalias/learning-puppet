define jboss::cli::sysproperty_add($user, $password, $name, $value, $jbossroot, $timeout = 300) {
       # run this command: 
       # jboss-cli.sh --user=admin --password=password --connect --command="/system-property=property:add(value=value)"
  info("Adding JBoss system property: $name = $value")
  
       exec { "jboss-cli-set-property-$name-$value":
       	    command => "$jbossroot/bin/jboss-cli.sh --user=$user --password=$password --connect  --command=\/system-property=$name:add\(value=$value\)",
		# only run if the system property doesn't exist yet, to prevent multiple overriding executions
		# TODO: make it so that callers of this defined resource can force override, and in that case we'd need a delete first and then an add
	    onlyif => "$jbossroot/bin/jboss-cli.sh --user=$user --password=$password --connect --command=\/system-property=$name:read-resource|grep failed",
            tries => 3,
            timeout => $timeout,
            try_sleep => 60,
       }  
}

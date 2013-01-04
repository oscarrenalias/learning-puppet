define jboss::cli::sysproperty_add($user, $password, $name, $value, $jbossroot) {
       # run this command: 
       # jboss-cli.sh --user=admin --password=password --connect --command="/system-property=property:add(value=value)"
       exec { "jboss-cli-set-property-$name-$value":
       	    command => "$jbossroot/bin/jboss-cli.sh --user=$user --password=$password --connect  --command=\/system-property=$name:add\(value=$value\)"
       }
}
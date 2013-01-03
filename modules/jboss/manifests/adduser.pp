# Function that adds users to JBoss
define jboss::adduser($name = $title, $password, $type, $jbosspath) {
	if($password == "") {
		fail("Empty passwords are not allowed")
	}

	if($jbosspath == "") {
		fail("Please provide the path to the JBoss base installation folder")
	}

	# check what type of user must be created and then run the correct command
	case $type {
		"management": { $command = "add-user.sh --silent=true $name $password" }
		"application": { $command = "add-user.sh --silent=true -a $name $password" }
		default: { fail("User type must either be 'management' or 'application'") }
	}

	exec { "adduser-$name":
		command => "$jbosspath/bin/$command"
	}
}

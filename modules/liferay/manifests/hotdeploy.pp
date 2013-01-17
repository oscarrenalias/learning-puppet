#
# Deploys files to Liferay using its hotdeploy mechanism
#
define liferay::hotdeploy(
  $source = $title,
  $package,
  $liferayhome,
  $jbosshome
) {
  #file { "liferay-hotdeploy-$source":
  #  source => $source,
  #  path => "$liferayhome/deploy/$package",
  #  owner => "jboss",
  #  group => "jboss",
  #}
  exec { "liferay-hotdeploy-$source":
    command => "cp $source $liferayhome/deploy/$package",
    path => [ "/bin", "/usr/bin" ],
    creates => "$jbosshome/standalone/deployments/$package",
    notify => Exec["fix-hotdeploy-permissions"],
  }

  exec { "fix-hotdeploy-permissions":
    command => "chown jboss:jboss $liferayhome/deploy/$package",
    path => ["/bin", "/usr/bin"],
  }
}

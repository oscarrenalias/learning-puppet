#
# Deploys files to Liferay using its hotdeploy mechanism
#
define liferay::hotdeploy(
  $source = $title,
  $package,
  $liferayhome
) {
  file { "liferay-hotdeploy-$source":
    source => $source,
    path => "$liferayhome/deploy/$package",
    owner => "jboss",
    group => "jboss",
  }
}

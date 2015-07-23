# == Class: sfu_yaml_to_puppetdsl
#
# init class to accept yaml location, nodefqdn that the yaml is for and the filename to print its built Puppet DSL manifest to.
#
#
# === Authors
#
# Adam S <asa188@sfu.ca>
#
# === Copyright
#
# Copyright 2015 Simon Fraser University, unless otherwise noted.
#
class sfu_yaml_to_puppetdsl($my_yaml = undef, $nodefqdn = $::fqdn, $filename_out = "/tmp/${::fqdn}.pp") {
  $myreturn = node_yaml_to_manifest($my_yaml, $nodefqdn, $filename_out)
  #notify { $myreturn: }
  #file { "/tmp/${::fqdn}.pp":
  #  content => template('sfu_tester/manifest.erb')
  #}
}

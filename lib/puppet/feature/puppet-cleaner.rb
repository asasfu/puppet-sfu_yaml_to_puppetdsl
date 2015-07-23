# This is if we wanted to use puppet-cleaner inside of a type/provider instead of a parser
#require 'puppet/util/feature'
#Puppet.features.add(:puppet-cleaner) do
#  begin
#    require 'puppet-cleaner'
#  rescue ArgumentError
#    raise Puppet::Error, "The version of puppet-cleaner on the system is too old. " +
#      "Please ensure that you have version '0.3.1' of the puppet-cleaner gem " +
#      "installed on the system."
#    return false
#  end
#  true
#end

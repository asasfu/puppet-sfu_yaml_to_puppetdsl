puppet-sfu_yaml_to_puppetdsl
======

sfu_yaml_to_puppetdsl for use with puppet and foreman and/or fancyass(SFU item)

Documentation
-------------

Documentation for this and related projects can be found online at the
https://github.com/asasfu/sfu_yaml_to_puppetdsl

Dependency
----------

Load a YAML file containing a hash, and build it as a node manifest
Uses puppet-cleaner gem, the safe forked copy at https://github.com/asasfu/puppet-cleaner (no gem dependency on puppet)
Clone 'https://github.com/asasfu/puppet-cleaner' and then run `gem install --local puppet-cleaner/puppet-cleaner-0.3.1.gem`

Useful for if you have the node's YAML from puppet and want to test it directly on a client with local modules installed


Installation
------------

This module takes in a foreman or fancyass created YAML and converts it back to Puppet DSL

Usage
-----

Defaults for this module contains the nodefqdn and filename_out, my_yaml MUST be provided.  This may be overridden in your puppet configs by calling any of the following:

  ```puppet
  class { sfu_yaml_to_puppetdsl: 
    my_yaml      => '/tmp/rcg-pineneedle.rcg.sfu.ca.yaml'
  }
  ```
  or

  ```puppet
  class { sfu_yaml_to_puppetdsl: 
    my_yaml      => '/tmp/rcg-pineflake.rcg.sfu.ca.yaml',
    nodefqdn     => 'rcg-pineflake.rcg.sfu.ca',
    filename_out => '/tmp/rcg-pineflake.rcg.sfu.ca'
  }
  ```
You can use one or both values

Once the manifest is compiled you should notice that in order to run it properly, you need to download(git clone or puppet module install) the modules that it will be referencing.  This will allow you to test out version conflicts and dependency issues before applying upgraded modules into production.  This is one of the options if you don't have a spinup of a second full puppet infrastructure(puppet still has types/providers and fact bleed so environment testing of certain modules in dev env. is not safe)

Developing and Contributing
---------------------------

We'd love to get contributions from you!
We're always curious how we can make this more functional and modular for everyone's greater good in systems' automation

License
-------

See LICENSE.md file.

Support
-------

There is no expectation of support for this module but we will in all attempts work on maintaining it to support our wide uses of linux

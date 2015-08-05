puppet-sfu_yaml_to_puppetdsl
======

sfu_yaml_to_puppetdsl for use with puppet and foreman and/or fancyass(SFU item)

Documentation
-------------

Documentation for this and related projects can be found online at the
https://github.com/asasfu/sfu_yaml_to_puppetdsl

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

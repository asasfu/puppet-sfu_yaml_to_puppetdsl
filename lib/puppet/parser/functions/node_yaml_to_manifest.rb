

module Puppet::Parser::Functions


  newfunction(:node_yaml_to_manifest, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
    confine :kernel => 'Linux' 

    Load a YAML file containing a hash, and build it as a node manifest 
    Uses puppet-cleaner gem safe forked copy at https://github.com/asasfu/puppet-cleaner (no gem dependency on puppet)
    Clone 'https://github.com/asasfu/puppet-cleaner' and then run `gem install --local puppet-cleaner/puppet-cleaner-0.3.1.gem`

    Useful for if you have the node's YAML from puppet and want to test it directly on a client
    with local modules installed
    Such as 'puppet apply my-node-fqdn.pp'
    And inside your my-node-fqdn.pp you will place
    node my-node-fqdn {
      node_yaml_to_manifest('File-location-of-node-yaml.yaml',"node's FQDN")
    }

    #For example:

    #    $myhash = node_yaml_to_manifest('/etc/puppet/data/myhash.yaml', 'rcg-pineneedle.rcg.sfu.ca')
    #    $myhash = node_yaml_to_manifest('/etc/puppet/data/myhash.yaml', 'rcg-pineneedle.rcg.sfu.ca', '/tmp/rcg-pineneedle.rcg.sfu.ca.pp')
    ENDHEREDOC

    unless args.length >= 2
      raise Puppet::ParseError, ("node_yaml_to_manifest(): wrong number of arguments (#{args.length}; must be 2 or 3) (yaml_filename, node_fqdn, optional_outputfilename)")
    end

    data = YAML.load_file(args[0])
    nodefqdn = args[1]
    filename_out = args[2]
    # If filename was not defined or empty string, set it to /tmp/fqdn.pp
    if filename_out.nil? or filename_out.empty?
      filename_out = "/tmp/#{nodefqdn}.pp"
    end

    # Supports foreman YAML or fancyass YAML (basically with or without the classes: root key in YAML)
    # Does not support /var/lib/puppet/yaml/node/fqdn.yaml as those are of a slightly different format
    values = function_keys([data])
    if values[0] != 'classes'
      values = data
    else
      values = function_values([data])
      values = values[0]
    end
    subvalue = function_values([values])
    nestedvalues = function_keys([values])

    # Prepare the formatting strings for our part of preparation of a clean DSL manifest
    symbolcolon = Regexp.new(/:(?=(?:(?:\\.|[^"\\])*"(?:\\.|[^"\\])*")*(?:\\.|[^"\\])*\Z)/)
    hierafactregex = Regexp.new(/\%\{::/)
    keyvaluesep = Regexp.new(/=>\s*\{/)
    allbracket = Regexp.new(/([\[\{])(?!\s?\n)(?=(?:(?:\\.|[^"\\])*"(?:\\.|[^"\\])*")*(?:\\.|[^"\\])*\Z)/)
    allbackbracket = Regexp.new(/([\]\}])(?!\s?\n)(?=(?:(?:\\.|[^"\\])*"(?:\\.|[^"\\])*")*(?:\\.|[^"\\])*\Z)/)
    space_not_in_quotes = Regexp.new(/ (?=(?:(?:\\.|[^"\\])*"(?:\\.|[^"\\])*")*(?:\\.|[^"\\])*\Z)/)

    hasharray = []
    # Append begining node manifest details
    hasharray << "node \'#{nodefqdn}\' {\n"

    # Begin parsing of YAML to puppet DSL
    nestedvalues.each_index do |hashindex|
      if ! subvalue[hashindex].nil? && ! subvalue[hashindex].empty? 

        sub_to_sub = subvalue[hashindex]
        sub_to_sub = sub_to_sub.deep_symbolize_keys
        sub_to_sub = "#{sub_to_sub}"
        sub_to_sub[0] = ''
        sub_to_sub[-1] = ''
        sub_to_sub.gsub!(symbolcolon, '') 
        sub_to_sub.gsub!(hierafactregex, '${::') 
        sub_to_sub.gsub!(keyvaluesep, "=>\{\n") 
        sub_to_sub.gsub!(allbracket,"\\1\n")
        sub_to_sub.gsub!(allbackbracket,"\n\\1")
        sub_to_sub.gsub!(space_not_in_quotes, "\n") 

        # for debugging
        # puts "SUB: #{sub_to_sub}"
        hasharray << "class { '#{nestedvalues[hashindex]}': \n #{sub_to_sub} \n}"
        # Disabled as we now output file inside of this module
        # function_create_resources([ 'class', { nestedvalues[hashindex] => subvalue[hashindex] } ])
      else 
        hasharray << "include #{nestedvalues[hashindex]}"
        # Disabled as we now output file inside of this module
        # function_include([ nestedvalues[hashindex] ])
      end
    end 

    # Append trailing closing bracket for node manifest
    hasharray << "}\n"

    
    # Write our file out temporarily as puppet-cleaner takes files in, not sure how to feed it data otherwise
    writeFile(filename_out, hasharray)

    # Begin puppet-cleaner handling
    pupclean = Puppet_clean_sfu::Open.new
    writeFile(filename_out,pupclean.run_puppet_cleaner(filename_out))

    # Send results, hasharray CAN, be used to pass to some other function usage, but is not really planned or suggested at this moment
    # This class really stands on its own right now.
    # If you wish to have immediate results rather than print a manifest or as well as, ask Adam or 
    # Uncomment those function_create_resources and function_include lines AND
    # Create a boolean arg[3] to say if true then run those two above function lines, this wont allow you to reorganize broken declaration classes 
    # Such as the currently broken mit_krb5 class which ends up out of order as it stands, have to move the base class to the last in the list
    puts "Wrote resulting YAML to puppet node manifest to #{filename_out}" 
    puts "Take a look at that file and verify it is correct, certain modules may need their declarations re-ordered"
    return hasharray

  end

end

# This allows us to convert all Hash keys from strings(which don't work in puppet DSL to symbols, which also don't work in puppet DSL)
# We then in our parsing, regex for all symbols and remove their initial colon so it matches puppet DSL
# Easier than tracking string keys and removing their quotes it seems
class Object
  def deep_symbolize_keys
    return self.reduce({}) do |item, (k, v)|
      item.tap { |m| m[k.to_sym] = v.deep_symbolize_keys }
    end if self.is_a? Hash
    
    return self.reduce([]) do |item, v| 
      item << v.deep_symbolize_keys; item
    end if self.is_a? Array
    
    self
  end
end

def writeFile(file, content)
  wr_file = File.open(file,'w')
  if content.kind_of? Array
    content.each do |line|
      wr_file.write(line+"\n")
    end
  else
    wr_file.write(content)
  end
  wr_file.close
end

module Puppet_clean_sfu
  class Open
    require 'puppet-cleaner'
    def run_puppet_cleaner(filename)
      # Create all the constraint values here from Puppet-cleaner, as we cannot fire up their ruby bin(I don't know how)
      # So this is basically a copy of their ruby bin file commands with some changes, they print to stdout, so we capture stdout for that one specific command
      self.class.const_set("ALL", [
          Puppet::Cleaner::MultilineComments.new,
          Puppet::Cleaner::SoftTabs.new,
          Puppet::Cleaner::UnneededQuotes.new,
          Puppet::Cleaner::TrailingWhitespace.new,
          Puppet::Cleaner::TrailingWhitespaceInComments.new,
          Puppet::Cleaner::AlignFarrow.new,
          Puppet::Cleaner::OctalMode.new,
          Puppet::Cleaner::ResourceTitles.new,
          Puppet::Cleaner::EnsureFirst.new,
          Puppet::Cleaner::QuotedBooleans.new,
          Puppet::Cleaner::Symlink.new
        ]
      )
      workers = Puppet_clean_sfu::Open::ALL
      line = Puppet::Cleaner.open(filename)
      inspect = Puppet::Cleaner.inspect
      line.hire(workers)
      line.transform!
      # They print to stdout, so we capture stdout for that one specific command
      retline = with_captured_stdout { line.show }
      retline = retline.to_s
      return retline
    end

    # Stdout capturing method for use with single commands, to avoid capturing more than we want
    def with_captured_stdout
      begin
        old_stdout = $stdout
        $stdout = StringIO.new('','w')
        yield
        $stdout.string
      ensure
        $stdout = old_stdout
      end
    end
  end
end

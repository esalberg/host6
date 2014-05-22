require 'puppet/provider/parsedfile'

hosts = nil
case Facter.value(:osfamily)
when "Solaris"; hosts = "/etc/inet/hosts"
when "windows"
  require 'win32/resolv'
  hosts = Win32::Resolv.get_hosts_path
else
  hosts = "/etc/hosts"
end


Puppet::Type.type(:host6).provide(:parsed,:parent => Puppet::Provider::ParsedFile,
  :default_target => hosts,:filetype => :flat) do
  confine :exists => hosts

  text_line :comment, :match => /^#/
  text_line :blank, :match => /^\s*$/

  record_line :parsed, :fields => %w{ip hostname host_aliases comment},
    :optional => %w{host_aliases comment},
    :match    => /^(\S+)\s+(\S+)\s*(.*?)?(?:\s*#\s*(.*))?$/,
    :post_parse => proc { |hash|
      # An absent comment should match "comment => ''"
    Puppet.debug "#{hash.inspect}"
      hash[:comment] = '' if hash[:comment].nil? or hash[:comment] == :absent
      unless hash[:host_aliases].nil? or hash[:host_aliases] == :absent
        hash[:host_aliases].gsub!(/\s+/,' ') # Change delimiter
      end
      hash[:name] = hash[:ip]
    },
    :to_line  => proc { |hash|
      [:ip, :hostname].each do |n|
        raise ArgumentError, "#{n} is a required attribute for hosts" unless hash[n] and hash[n] != :absent
      end
      str = "#{hash[:ip]}\t#{hash[:hostname]}"
      if hash.include? :host_aliases and !hash[:host_aliases].nil? and hash[:host_aliases] != :absent
        str += "\t#{hash[:host_aliases]}"
      end
      if hash.include? :comment and !hash[:comment].empty?
        str += "\t# #{hash[:comment]}"
      end
      str
    }
end

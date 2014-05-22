#! /usr/bin/env ruby
require 'spec_helper'

provider_class = Puppet::Type.type(:host6).provider(:parsed)

describe provider_class do

  before do
    @host_class = Puppet::Type.type(:host6)
    @provider = @host_class.provider(:parsed)
    @hostfile = '/tmp/hosts'

  end

  after :each do
    @provider.initvars
  end

  def mkhost(args)
    hostresource = Puppet::Type::Host6.new(:name => args[:name])
    hostresource.stubs(:should).with(:target).returns @hostfile

    # Using setters of provider to build our testobject
    # Note: We already proved, that in case of host_aliases
    # the provider setter "host_aliases=(value)" will be
    # called with the joined array, so we just simulate that
    host = @provider.new(hostresource)
    args.each do |property,value|
      value = value.join(" ") if property == :host_aliases and value.is_a?(Array)
      host.send("#{property}=", value)
    end
    host
  end

  def genhost(host)
    @provider.stubs(:filetype).returns(Puppet::Util::FileType::FileTypeRam)
    File.stubs(:chown)
    File.stubs(:chmod)
    Puppet::Util::SUIDManager.stubs(:asuser).yields
    host.flush
    @provider.target_object(@hostfile).read
  end

  describe "when parsing a line with ip and hostname" do

    it "should parse an ipv4 from the first field" do
      @provider.parse_line("127.0.0.1    localhost")[:ip].should == "127.0.0.1"
    end

    it "should parse an ipv6 from the first field" do
      @provider.parse_line("::1     localhost")[:ip].should == "::1"
    end

    it "should parse the name from the second field" do
      @provider.parse_line("::1     localhost")[:hostname].should == "localhost"
    end

    it "should set an empty comment" do
      @provider.parse_line("::1     localhost")[:comment].should == ""
    end

    it "should set host_aliases to :absent" do
      @provider.parse_line("::1     localhost")[:host_aliases].should == :absent
    end

  end

  describe "when parsing a line with ip, hostname and comment" do
    before do
      @testline = "127.0.0.1   localhost # A comment with a #-char"
    end

    it "should parse the ip from the first field" do
      @provider.parse_line(@testline)[:ip].should == "127.0.0.1"
    end

    it "should parse the hostname from the second field" do
      @provider.parse_line(@testline)[:hostname].should == "localhost"
    end

    it "should parse the comment after the first '#' character" do
      @provider.parse_line(@testline)[:comment].should == 'A comment with a #-char'
    end

  end

  describe "when parsing a line with ip, hostname and aliases" do

    it "should parse alias from the third field" do
      @provider.parse_line("127.0.0.1   localhost   localhost.localdomain")[:host_aliases].should == "localhost.localdomain"
    end

    it "should parse multiple aliases" do
      @provider.parse_line("127.0.0.1 host alias1 alias2")[:host_aliases].should == 'alias1 alias2'
      @provider.parse_line("127.0.0.1 host alias1\talias2")[:host_aliases].should == 'alias1 alias2'
      @provider.parse_line("127.0.0.1 host alias1\talias2   alias3")[:host_aliases].should == 'alias1 alias2 alias3'
    end

  end

  describe "when parsing a line with ip, hostname, aliases and comment" do

    before do
      # Just playing with a few different delimiters
      @testline = "127.0.0.1\t   host  alias1\talias2   alias3   #   A comment with a #-char"
    end

    it "should parse the ip from the first field" do
      @provider.parse_line(@testline)[:ip].should == "127.0.0.1"
    end

    it "should parse the hostname from the second field" do
      @provider.parse_line(@testline)[:hostname].should == "host"
    end

    it "should parse all host_aliases from the third field" do
      @provider.parse_line(@testline)[:host_aliases].should == 'alias1 alias2 alias3'
    end

    it "should parse the comment after the first '#' character" do
      @provider.parse_line(@testline)[:comment].should == 'A comment with a #-char'
    end

  end

end

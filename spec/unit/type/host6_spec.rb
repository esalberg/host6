require 'spec/spec_helper.rb'

describe Puppet::Type.type(:host6) do
  before do
    @type = Puppet::Type.type(:host6)
    @provider = @type.provider(:parsed)
    @resource = double 'resource', :resource => nil, :provider => @provider
  end

  after :each do
    @provider.initvars
  end

  it "should exist" do
    Puppet::Type.type(:host6).should_not be_nil
  end

  describe "the ip parameter" do
    it "should exist" do
      @type.attrclass(:ip).should_not be_nil
    end
    describe "should validate ip addresses" do
      it "should allow a vaild IPv4 address" do
        proc { @type.new(:ip => '127.0.0.1') }.should_not raise_error
      end
      it "should allow a valid IPv6 address" do
        proc { @type.new(:ip => 'fe80::5054:ff:feda:4242') }.should_not raise_error
      end
      it "should fail a invalid IPv4 address" do
        proc { @type.new(:ip => '256.256.256.256') }.should raise_error
      end
      it "should fail a invalid IPv6 address" do
        proc { @type.new(:ip => 'fe80::5054:ff:feda:4242:') }.should raise_error
      end
    end
  end
end

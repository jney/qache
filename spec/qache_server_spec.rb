require File.join(File.dirname(__FILE__), "spec_helper")
require "qache/server"

module QacheServerSpecHelper
  def logger_options
    {
      :logger    => File.join(File.dirname(__FILE__), *%w(.. log logger.log)),
      :log_level => "DEBUG"
    }
  end
  
  def process_exists?(str)
    !(IO.popen('ps aux').read =~ /#{str}/).nil?
  end
end

describe "qache server" do
  include QacheServerSpecHelper
  
  it "should start a server with default values" do
    @server = Qache::Server.new(logger_options)
    # we run memcacheq
    @server.run
    # check if memcacheq is started
    process_exists?("memcacheq").should be_true
    # we stop memcacheq
    @server.stop
    process_exists?("memcacheq").should be_false
  end
  
  describe "options" do
    it "should set a default address to 127.0.0.1:22201" do
      @server = Qache::Server.new(logger_options)
      @server.address.should == "127.0.0.1:22201"
    end
    
    it "should set address while changing the host" do
      @server = Qache::Server.new(logger_options.merge(:host => "192.168.1.12"))
      @server.address.should == "192.168.1.12:22201"
    end
    
    it "should set address while changing the port" do
      @server = Qache::Server.new(logger_options.merge(:port => "3333"))
      @server.address.should == "127.0.0.1:3333"
    end
  end
end
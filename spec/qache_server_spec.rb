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
    # check if memcacheq is stopped
    process_exists?("memcacheq").should be_false
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
    it "should deamonize" do
      @server = Qache::Server.new(logger_options.merge({:daemonize => true}))
      @server.daemonize?.should be_true
    end
    
    it "should deamonize" do
      @server = Qache::Server.new(logger_options.merge({:daemonize => false}))
      @server.daemonize?.should be_false
    end
  end
end
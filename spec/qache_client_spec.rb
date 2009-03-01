require File.join(File.dirname(__FILE__), "spec_helper")
require "qache"

describe "qache client" do
  # before we start a memcachedb server
  before(:all) do
    @server = Qache::Server.start
  end
  
  # after we stop memcachedb server
  after(:all) do
    @server.stop
  end
  
  it "should start a client" do
    # then we start a server
    @client = Qache::Client.new
  end
end
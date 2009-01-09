require File.join(File.dirname(__FILE__), "spec_helper")
require "qache"

describe "qache client" do
  it "should start a client" do
    puts "mmmmm"
    # first we start a server
    @server = Qache::Server.start
    # then we start a server
    @client = Qache::Client.new
    @server.stop
    # wait some seconds to me sure the process is stopped
    10.downto(0) { |i| sleep(1); puts i }
  end
end
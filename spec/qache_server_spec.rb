require File.join(File.dirname(__FILE__), "spec_helper")
require "qache/server"

module QacheServerSpecHelper
  def logger_options
    {
      :logger    => File.join(File.dirname(__FILE__), *%w(.. log logger.log)),
      :log_level => "DEBUG"
    }
  end
end

describe "qache server" do
  include QacheServerSpecHelper
  
  it "should start a server with default values" do
    Qache::Server.start(logger_options)
  end
end
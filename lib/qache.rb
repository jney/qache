require "rubygems"
require "memcache"

require File.join(File.dirname(__FILE__), 'qache', 'client')
require File.join(File.dirname(__FILE__), 'qache', 'server')

module Qache
  VERSION = '0.0.1'
end
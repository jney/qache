require "socket"
require "logger"
require "rubygems"
require "analyzer_tools/syslog_logger"

here = File.dirname(__FILE__)

# require File.join(here, "handler")

module Qache
  class Server
    attr_reader :logger

    DEFAULT_DAEMONIZE       = true          unless defined?(DEFAULT_DAEMONIZE)
    DEFAULT_FILE            = "data.db"     unless defined?(DEFAULT_FILE)
    DEFAULT_HOST            = "127.0.0.1"   unless defined?(DEFAULT_HOST)
    DEFAULT_PATH            = "/tmp/qache/" unless defined?(DEFAULT_PATH)
    DEFAULT_PID_FILE        = "qache.pid"   unless defined?(DEFAULT_PID_FILE)
    DEFAULT_PORT            = 22201         unless defined?(DEFAULT_PORT)
    DEFAULT_THREADS_NUMBER  = 4             unless defined?(DEFAULT_THREADS_NUMBER)
    DEFAULT_TIMEOUT         = 60            unless defined?(DEFAULT_TIMEOUT)

    ##
    # Initialize a new memcacheQ server and immediately start processing
    # requests.
    #
    # +opts+ is an optional hash, whose valid options are:
    #
    #   [:host]     Host on which to listen (default is 127.0.0.1).
    #   [:port]     Port on which to listen (default is 22122).
    #   [:path]     Path to memcacheQ queue logs. Default is /tmp/qache/
    #   [:timeout]  Time in seconds to wait before closing connections.
    #   [:logger]   A Logger object, an IO handle, or a path to the log.
    #   [:loglevel] Logger verbosity. Default is Logger::ERROR.
    #
    # Other options are ignored.
    def self.start(opts = {})
      new(opts).run
    end

    ##
    # Initialize a new Starling server, but do not accept connections or
    # process requests.
    #
    # +opts+ is as for +start+
    def initialize(opts = {})
      @opts = {
        :daemonize      => DEFAULT_DAEMONIZE,
        :host           => DEFAULT_HOST,
        :path           => DEFAULT_PATH,
        :pid_file       => DEFAULT_PID_FILE,
        :port           => DEFAULT_PORT,
        :threads_number => DEFAULT_THREADS_NUMBER,
        :timeout        => DEFAULT_TIMEOUT
      }.merge(opts)
      
      @stats = {}
    end

    ##
    # Start listening and processing requests.
    def run
      @stats[:start_time] = Time.now

      @@logger = case @opts[:logger]
                 when IO, String; Logger.new(@opts[:logger])
                 when Logger; @opts[:logger]
                 else; Logger.new(STDERR)
                 end
      @@logger = SyslogLogger.new(@opts[:syslog_channel]) if @opts[:syslog_channel]

      @@logger.level = eval("Logger::#{@opts[:log_level].upcase}") rescue Logger::ERROR

      STDOUT.puts "memcacheq STARTUP on #{address}"
      @@logger.info "memcacheq STARTUP on #{address}"

      command = [
        "memcacheq",
        ("-d" if daemonize?),
        "-l #{@opts[:host]}",
        "-H #{@opts[:path]}",
        ("-P #{@opts[:pid_file]}" if daemonize?), # can only be used if in daemonize mode
        "-p #{@opts[:port]}",
        "-t #{@opts[:threads_number]}"
      ].compact.join(' ')
      
      unless system(*command)
        STDERR.puts "memcacheq error while starting #{address}"
        @@logger.info "memcacheq error while starting #{address}"
        raise 
      end
    end

    def self.logger
      @@logger
    end
    
    ##
    # Stop accepting new connections and shutdown gracefully.
    def stop(code=3)
      STDOUT.puts "Stopping memcacheq..."
      Process.kill(code, stats["pid"])
    end

    def stats(stat = nil) #:nodoc:
      @stats.merge(client.stats[address])
    end

    ##
    # Return full host string host:port
    def address
      @address ||= "#{@opts[:host]}:#{@opts[:port]}"
    end
    
    ## 
    # Return a basic memcache client
    def client
      @client ||= MemCache.new(address)
    end
    
    def daemonize?
      @opts[:daemonize]
    end
  end
end

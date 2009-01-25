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
    # +options+ is an optional hash, whose valid options are:
    #
    #   [:host]     Host on which to listen (default is 127.0.0.1).
    #   [:port]     Port on which to listen (default is 22122).
    #   [:path]     Path to memcacheQ queue logs. Default is /tmp/qache/
    #   [:timeout]  Time in seconds to wait before closing connections.
    #   [:logger]   A Logger object, an IO handle, or a path to the log.
    #   [:loglevel] Logger verbosity. Default is Logger::ERROR.
    #
    # Other options are ignored.
    def self.start(options = {})
      server = new(options)
      server.run
      return server
    end

    ##
    # Initialize a new Starling server, but do not accept connections or
    # process requests.
    #
    # +options+ is as for +start+
    def initialize(options = {})
      @options = {
        :daemonize      => DEFAULT_DAEMONIZE,
        :host           => DEFAULT_HOST,
        :path           => DEFAULT_PATH,
        :pid_file       => DEFAULT_PID_FILE,
        :port           => DEFAULT_PORT,
        :threads_number => DEFAULT_THREADS_NUMBER,
        :timeout        => DEFAULT_TIMEOUT
      }.merge(options)
      
      @stats = {}
    end

    ##
    # Return full host string host:port
    def address
      @address ||= "#{@options[:host]}:#{@options[:port]}"
    end

    ## 
    # Return a basic memcache client
    def client
      @client ||= MemCache.new(address)
    end

    def daemonize?
      @options[:daemonize]
    end

    ##
    # Start memcacheq server with wanted options
    # TODO:
    # manage if a process is already running
    def run
      @stats[:start_time] = Time.now

      @@logger = case @options[:logger]
                 when IO, String  then Logger.new(@options[:logger])
                 when Logger      then @options[:logger]
                 else; Logger.new(STDERR)
                 end
      @@logger = SyslogLogger.new(@options[:syslog_channel]) if @options[:syslog_channel]

      @@logger.level = eval("Logger::#{@options[:log_level].upcase}") rescue Logger::ERROR

      command = [
        "memcacheq",
        ("-d" if daemonize?),
        "-l #{@options[:host]}",
        "-H #{@options[:path]}",
        ("-P #{@options[:pid_file]}" if daemonize?), # can only be used if in daemonize mode
        "-p #{@options[:port]}",
        "-t #{@options[:threads_number]}"
      ].compact.join(' ')
      
      log("STARTING UP on #{address}")
      log("with command #{command}")
      # fork do
      #   begin
      #     exec("mm") 
      #   rescue
      #     
      #   end
      # end
      unless system(*command)
        log("ERROR while starting #{address}", :error)
        raise 
      end
    end

    def self.logger
      @@logger
    end
    
    def pid
      @pid ||= stats["pid"]
    end
    
    ##
    # Stop accepting new connections and shutdown gracefully.
    def stop(code=3, wait_while_stopping=false)
      log("STOPPING...")
      Process.kill(code, pid)
      if wait_while_stopping
        # FIXME got error using Process.waitpid(pid)
      end
    end
    
    ##
    # Stop every memcached process.
    # FIXME: a little bit too hardcore now
    def self.stop(code=3)
      pids = IO.popen('ps ax').readline.collect do |line|
        if line =~ /[ ]*(\d+).*memcacheq.*/
          Process.kill(code, $1)
        end
      end
    end

    def stats(stat = nil) #:nodoc:
      @stats.merge(client.stats[address])
    end
    
    private
    def log(msg, severity = :info)
      case severity
      when :info
        STDOUT.puts "\n[qache] #{msg}"
        @@logger.info "[qache] #{msg}"
      when :error
        STDERR.puts "\n[qache] #{msg}"
        @@logger.error "[qache] #{msg}"
      end
    end
  end
end

require "rubygems"
require "memcache"

# module Qache
#   VERSION = '0.0.1'
# end

module Qache
  class Client < MemCache
  
    attr_writer :db_stat
  
    ##
    # Removes +queue+ from the memcacheq
    def delete(queue)
      @mutex.lock if @multithread

      raise MemCacheError, "No active servers" unless active?
      cache_key = make_cache_key key
      server = get_server_for_key cache_key

      sock = server.socket
      raise MemCacheError, "No connection to server" if sock.nil?

      begin
        sock.write "delete #{cache_key}\r\n"
        sock.gets
      rescue SocketError, SystemCallError, IOError => err
        server.close
        raise MemCacheError, err.message
      end
    ensure
      @mutex.unlock if @multithread
    end
  
    ##
    # returns a list of available (currently allocated) queues.
    def available_queues(statistics = nil)
      raise MemCacheError, "No active servers" unless active?

      @servers.first = server
      sock = server.socket
      raise MemCacheError, "No connection to server" if sock.nil?
    
      @available_queues = []
    
      value = nil
      begin
        sock.write "stats queue\r\n"
        stats = {}
        while line = sock.gets do
          break if line == "END\r\n"
          if line =~ /STAT [\w]+ ([\w\.\:]+)/ then
            @available_queues << $1
          end
        end
      rescue SocketError, SystemCallError, IOError => err
        server.close
        raise MemCacheError, err.message
      end

      @available_queues
    end
  
    ##
    # returns the number of items in +queue+. If +queue+ is +:all+, a hash of all
    # queue sizes will be returned.
    # FIXME:
    # For now only available with memcacheq running in local with default path
    def sizeof(queue, statistics = nil)
      statistics ||= stats

      if queue == :all
        available_queues.inject({}){|h,q| h[q] = sizeof(queue, statistics)}
      else
        IO.popen("#{db_stat} -d /tmp/qache/#{queue}").readlines.
          detect{|line| line =~ /(\d+)\tNumber of records in the database\n/ }
        $1.to_i
      end
    end
  
    def db_stat
      @db_stat ||= "/usr/local/BerkeleyDB.4.7/bin/db_stat"
    end
  end
end
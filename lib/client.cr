require "socket"

class Client

  getter server : String = "irc.freenode.net"
  getter port : Int32 = 6667
  getter nick : String = "crystal8509"
  getter user : String = "crystal8509"
  getter version : String = "crystal8509 v0.0.1"

  property client : TCPSocket
  property response_count : Int32 = 0

  def initialize
    @client = TCPSocket.new(@server, @port)
    
    while true
      sleep 0.1

      response = client.gets
      next unless response
      puts response
      @response_count += 1

      login
      privmsg(response)
      pong(response)
    end
    
    @client.close
  end

  def login
    return unless @response_count == 3
    @client << "PASS none\r\n"
    @client << "NICK #{nick}\r\n"
    @client << "USER #{user} 8 * :#{user}\r\n"
  end

  def version(response)
    return unless response.includes?("VERSION")
    puts "VERSION #{version}"
    @client << "VERSION #{version}\r\n"
  end

  def privmsg(response)
    return unless response.includes?("PRIVMSG")
    version(response)
  end

  def pong(response)
    return unless response.starts_with?("PING")
    parts = response.split(":")
    return unless parts.size == 2
    puts "PONG :#{parts[1]}"
    @client << "PONG :#{parts[1]}\r\n"
  end
end

require "json"
require "socket"

class Client
  getter version : String = "crystal-bot v0.0.1"

  property server : String = ""
  property port : Int32 = 6667
  property nick : String = ""
  property user : String = ""

  property client : TCPSocket
  property response_count : Int32 = 0

  def initialize
    configure
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

  def configure
    json = JSON.parse(File.read("config.json"))
    @server = json["server"].to_s
    @port = json["port"].to_s.to_i
    @nick = json["nick"].to_s
    @user = json["user"].to_s
  end
end

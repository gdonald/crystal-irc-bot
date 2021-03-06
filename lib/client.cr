require "json"
require "socket"

class Client
  getter version : String = "crystal-irc-bot v0.0.1"

  property server : String = ""
  property port : Int32 = 0
  property nick : String = ""
  property user : String = ""
  property password : String = ""
  property channels : Array(String) = [] of String

  property client : TCPSocket
  property response_count : Int32 = 0
  property logged_in : Bool = false
  property version_sent : Bool = false
  property channels_joined : Bool = false

  def initialize
    configure
    @client = TCPSocket.new(server, port)
    
    while true
      sleep 0.1
      response = get_response
      next unless response

      login
      privmsg(response)
      join_channels
      break if logged_in && version_sent && channels_joined
    end

    while true
      sleep 0.1
      response = get_response
      next unless response

      pong(response)
    end
    
    client.close
  end

  def login
    return unless @response_count == 3
    client << "PASS #{password}\r\n"
    client << "NICK #{nick}\r\n"
    client << "USER #{user} 8 * :#{user}\r\n"
    @logged_in = true
  end

  def version(response)
    return unless response.includes?("VERSION")
    puts "VERSION #{version}"
    client << "VERSION #{version}\r\n"
    @version_sent = true
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
    client << "PONG :#{parts[1]}\r\n"
  end

  def get_response
    response = @client.gets
    if response
      puts response
      @response_count += 1
    end
    response
  end

  def join_channels
    return unless version_sent || channels_joined
    channels.each do |channel|
      client << "JOIN #{channel}\r\n"
      sleep 0.2
    end
    @channels_joined = true
  end

  def configure
    json = JSON.parse(File.read("config.json"))
    @server = json["server"].to_s
    @port = json["port"].to_s.to_i
    @nick = json["nick"].to_s
    @user = json["user"].to_s
    @password = json["password"].to_s
    json["channels"].as_a.each do |channel|
      @channels.push(channel.as_s)
    end
  end
end

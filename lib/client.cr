require "socket"

class Client

  property nick : String = "crystal8509"
  property user : String = "crystal8509"
  property version : String = "crystal8509 v0.0.1"
  property response_count : Int32 = 0


  def initialize
    client = TCPSocket.new("irc.freenode.net", 6667)
    
    while true
      response = client.gets
      
      if response
        @response_count += 1
        puts response

        if @response_count == 3
          client << "PASS none\r\n"
          client << "NICK #{nick}\r\n"
          client << "USER #{user} 8 * :#{user}\r\n"
        end

        if response.starts_with?("PING")
          parts = response.split(":")
          if parts.size == 2
            puts "PONG :#{parts[1]}"
            client << "PONG :#{parts[1]}\r\n"
          end
        end

        if response.includes?("PRIVMSG")
          if response.includes?("VERSION")
            puts "VERSION #{version}"
            client << "VERSION #{version}\r\n"
          end
        end
      end

      sleep(0.1)
    end
    
    client.close
  end
end

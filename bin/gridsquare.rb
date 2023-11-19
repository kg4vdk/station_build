require 'gpsd_client'
require 'maidenhead'
require 'socket'
require 'json'

gpsd = GpsdClient::Gpsd.new()
gpsd.start()
apicmd = {}

# get maidenhead if gps is ready
if gpsd.started?
  pos = gpsd.get_position
  maid = Maidenhead.to_maidenhead(pos[:lat], pos[:lon], precision = 4)
  puts "lat = #{pos[:lat]}, lon = #{pos[:lon]}, grid = #{maid}"
  apicmd = {:type => "STATION.SET_GRID", :value => maid}
end
# send if we have data
unless maid == "JJ00aa00"
  File.open("/tmp/coords.log", "w") { |f| f.write "#{pos[:lat]},#{pos[:lon]}" }
  File.open("/tmp/grid.log", "w") { |f| f.write "#{maid}" }
  js8call_port = 2242
  js8call_running = `ps -aux | grep js8cal[l]`
  if js8call_running != "" then
    puts "JS8Call is running"
      Socket.udp_server_loop(js8call_port) { |msg, msg_src|
      if apicmd.length > 0 then
        puts "Sending #{apicmd}"
        msg_src.reply apicmd.to_json
        break
      end
  }
  else
    puts "JS8Call is NOT running"
  end
  wsjtx_port = 2237
  wsjtx_running = `ps -aux | grep wsjt[x]`
  if wsjtx_running != "" then
    puts "WSJTX is running"
      Socket.udp_server_loop(wsjtx_port) { |msg, msg_src|
      if apicmd.length > 0 then
        puts "Sending #{apicmd}"
        msg_src.reply apicmd.to_json
        break
      end
  }
  else
    puts "WSJTX is NOT running"
  end
else
  File.delete("/tmp/coords.log") if File.exist?("/tmp/coords.log")
  File.delete("/tmp/grid.log") if File.exist?("/tmp/grid.log")
  puts "Invalid GPS fix"
end

-- 192.168.255.80
-- 11000
local socket = require "socket"

local advertiseServer = function( button )
 
    local send = socket.udp()
    send:settimeout( 0 )  --this is important (see notes below)
 
    local stop
 
    local counter = 0  --using this, we can advertise our IP address for a limited time
 
    local function broadcast()
        local msg = "AwesomeGameServer"
        --multicast IP range from 224.0.0.0 to 239.255.255.255
        send:sendto( msg, "228.192.1.1", 11111 )
        --not all devices can multicast so it's a good idea to broadcast too
        --however, for broadcast to work, the network has to allow it
        send:setoption( "broadcast", true )  --turn on broadcast
        send:sendto( msg, "255.255.255.255", 11111 )
        send:setoption( "broadcast", false )  --turn off broadcast
 
        counter = counter + 1
        if ( counter == 80 ) then  --stop after 8 seconds
            stop()
        end
    end
 
    --pulse 10 times per second
    local serverBroadcast = timer.performWithDelay( 100, broadcast, 0 )
 
    button.stopLooking = function()
        timer.cancel( serverBroadcast )  --cancel timer
        button.stopLooking = nil
    end
    stop = button.stopLooking
end

local getIP = function()
    local s = socket.udp()  --creates a UDP object
    s:setpeername( "74.125.115.104", 80 )  --Google website
    local ip, sock = s:getsockname()
    print( "myIP:", ip, sock )
    return ip
end

local function findServer( button )
 
    local newServers = {}
    local msg = "AwesomeGameServer"
 
    local listen = socket.udp()
    listen:setsockname( "226.192.1.1", 11111 )  --this only works if the device supports multicast
 
    local name = listen:getsockname()
    if ( name ) then  --test to see if device supports multicast
        listen:setoption( "ip-add-membership", { multiaddr="226.192.1.1", interface = getIP() } )
    else  --the device doesn't support multicast so we'll listen for broadcast
        listen:close()  --first we close the old socket; this is important
        listen = socket.udp()  --make a new socket
        listen:setsockname( getIP(), 11111 )  --set the socket name to the real IP address
    end
 
    listen:settimeout( 0 )  --move along if there is nothing to hear
 
    local stop
 
    local counter = 0  --pulse counter
 
    local function look()
        repeat
            local data, ip, port = listen:receivefrom()
            --print( "data: ", data, "IP: ", ip, "port: ", port )
            if data and data == msg then
                if not newServers[ip] then
                    print( "I hear a server:", ip, port )
                    local params = { ["ip"]=ip, ["port"]=22222 }
                    newServers[ip] = params
                end
            end
        until not data
 
        counter = counter + 1
        if counter == 20 then  --stop after 2 seconds
            stop()
        end
     end
 
     --pulse 10 times per second
     local beginLooking = timer.performWithDelay( 100, look, 0 )
 
     function stop()
         timer.cancel( beginLooking )
         button.stopLooking = nil
         evaluateServerList( newServers ) --do something with your found servers
         listen:close()  --never forget to close the socket!
     end
     button.stopLooking = stopLooking
end

local function connectToServer( ip, port )
    local sock, err = socket.connect( ip, port )
    if sock == nil then
        return false
    end
    sock:settimeout( 0 )
    sock:setoption( "tcp-nodelay", true )  --disable Nagle's algorithm
    sock:send( "we are connected\n" )
    return sock
end


local function createClientLoop( sock, ip, port )
 
    local buffer = {}
    local clientPulse
 
    local function cPulse()
        local allData = {}
        local data, err
 
        repeat
            data, err = sock:receive()
            if data then
                allData[#allData+1] = data
            end
            if ( err == "closed" and clientPulse ) then  --try again if connection closed
                connectToServer( ip, port )
                data, err = sock:receive()
                if data then
                    allData[#allData+1] = data
                end
            end
        until not data
 
        if ( #allData > 0 ) then
            for i, thisData in ipairs( allData ) do
                print( "thisData: ", thisData )
                --react to incoming data 
            end
        end
 
        for i, msg in pairs( buffer ) do
            local data, err = sock:send(msg)
            if ( err == "closed" and clientPulse ) then  --try to reconnect and resend
                connectToServer( ip, port )
                data, err = sock:send( msg )
            end
        end
    end
 
    --pulse 10 times per second
    clientPulse = timer.performWithDelay( 100, cPulse, -1 )
 
    local function stopClient()
        timer.cancel( clientPulse )  --cancel timer
        clientPulse = nil
        sock:close()
    end
    return stopClient
end


local hello = connectToServer("192.168.255.80", 11000)
--local a = createClientLoop(hello,"192.168.255.80", 11000)
--if hello then print("hello true")
--else print("hello false")
--end
--print(tostring(hello))
if hello then print("connect! 192.168.255.80:11000") end
local a = createClientLoop(hello, "192.168.255.80", 11000)
--print(tostring(a))
--print(a)
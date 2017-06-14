math.randomseed( os.time() )

local physics = require "physics"
--local socket = require "socket"
local json = require "json"

local _W, _H = display.contentWidth, display.contentHeight

local CC = function(hex)
	local r = tonumber(hex:sub(1, 2), 16) / 255
	local g = tonumber(hex:sub(3, 4), 16) / 255
	local b = tonumber(hex:sub(5, 6), 16) / 255
	local a = 255/255
	if #hex == 8 then a = tonumber(hex:sub(7, 8), 16) end
	return r, g, b, a
end
local setAnchor = function(obj, xAnchor, yAnchor)
	obj.anchorX, obj.anchorY = xAnchor, yAnchor
end

local turnStage

local s00
local s01
local s02
local s03
local s04

local circle

local stageNum = 1
local life = 3

local heightMax
local heightMin
local heightNow
local ballHeight

--{"heightMax":0,"heightMin":0,"heightNow":84}
local loadData = function ( )
	local path = 'C:/Users/derba/Desktop/DMG/161210.Win32/Resources/data.txt'
	--print(path)
	--print("path : "..path)
	local file, errorString = io.open( path, "r" )


	if not file then
		print( "File error: " .. errorString )
	else
		local decoded, pos, msg  = json.decodeFile( path )

		if not decoded then
			print( "decode failed at".. tostring(pos)..": "..tostring(msg))
		else
			heightMax = decoded.heightMax
			heightMin = decoded.heightMin
			heightNow = decoded.heightNow
			--print("heightMax : "..heightMax.." heightMin : "..heightMin.." heightNow : "..heightNow)

		end

		io.close ( file )
	end

	file = nil
end

--[[
local connectToServer = function( ip, port )
	local sock, err = socket.connect( ip, port )
    if sock == nil then
        return false
    end
    sock:settimeout( 0 )
    sock:setoption( "tcp-nodelay", true )  --disable Nagle's algorithm
    return sock
end

local createClientLoop = function( sock, ip, port )
	if sock == nil then return false
	else print(tostring(sock))
	end

	local buffer = {}
    local clientPulse
 
    local function cPulse()
        local allData = {}
        local data, err
 
        repeat
            data, err = sock:receive()
            print("data : "..tostring(data).." err : "..tostring(err))

            if data then
                allData[#allData+1] = data
                local decoded, pos, msg = json.decode( data )

                if not decoded then
                	print("decode failed at"..tostring(pos)..": "..tostring(msg))
                else
                	ballHeight = decoded.ballHeight
                	ballMax = decoded.ballMax
                	ballMin = decoded.ballMin

                	realHeight = (ballMax - ballMin)
                end

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
    clientPulse = timer.performWithDelay( 100, cPulse, 0 )
   -- return stopClient
end
]]--

local ball = function( )
	loadData()
	circle.y = heightNow/heightMin*1080
--	print(heightNow.." "..heightMin.." "..heightMax)
	print(life)
--	ballHeight = circle.y
end

turnStage = function( )
	local goStage
	local textTimer
	local bg
	local box
	local lifeI = {}
	local id

	goStage = function ( )
		Runtime:removeEventListener( "touch", goStage )
		if id ~= nil then timer.cancel(id) end
		if life == 0 then
			life = 3
		else
			for i =1, life, 1 do
				lifeI[i]:removeSelf()
			end
		end
		box:removeSelf()
		bg:removeSelf()

		if stageNum == 1 then s01()
		elseif stageNum == 2 then s02()
		elseif stageNum == 3 then s03()
		end
	end

	textTimer = function ( e )
		id = e.source
		if box.alpha == 1 then box.alpha = 0
		end
	end

	if life <= 0 then
		bg = display.newImage( "over.png", 0, 0 )
		setAnchor( bg, 0, 0 )
	else
		bg = display.newImage("stage/"..stageNum..".png", 0, _H*0.55)
		bg.anchorX, bg.ahchorY = 0, 0

		for i = 1, life, 1 do
			lifeI[i] = display.newImage("life.png", _W*0.454+100*(i-1), _H*0.29)
		--	lifeI[i] = display.newImage("life2.png", _W*0.43+150*(i-1), _H*0.27)
		end
	end
		circle:removeSelf()
		circle = display.newCircle(_W*0.3, _H*0.5, 100, 100)
		circle.name = "circle"
		physics.addBody(circle, "dynamic", { bounce = 0, radius = 100 })
		circle.gravityScale = 0
		circle:setFillColor(CC("888888"))
		circle.alpha = 0.3
		box = display.newRect(_W*0.5, _H*0.68,_W*0.4,50)
		box:setFillColor(CC("000000"))
		box.alpha = 0

		timer.performWithDelay( 650, textTimer, -1 )
		Runtime:addEventListener( "touch", goStage )
end

s01 = function( )
	local monster
	local onPlace
	local shooting
	local dropMonster
	local onLocalCollision
	local onLocalCollisionWithCircle

	local id
	local id1

	local maxCount = 25
	local count = 0
	local countText = display.newText("enemy count : "..maxCount, _W*0.78, _H*0.1, native.newFont("정9체.ttf"))
	countText.size = 100

	onPlace = function ( e )
		circle.x = _W*0.3
	end

	onLocalCollision = function ( self, event )
		local phase = event.phase

		if phase == "began" then
			if self.name == "bullet" and event.other.name == "enemy" then
	--			print("collision -bullet -enemy")
				event.other:removeSelf()
				self:removeSelf()
				count = count + 1
				countText.text = "enemy count : "..maxCount-count
				if count == maxCount then
					timer.pause( id )
					if id ~= nil then timer.cancel(id) end
					if id1 ~= nil then timer.cancel(id1) end
					bar = nil
					bar2 = nil
					Runtime:removeEventListener( "enterFrame", onPlace )
					Runtime:removeEventListener( "collision", circle )
					stageNum = stageNum + 1
					countText:removeSelf()
					turnStage()
				end
			end
		end
	end

	onLocalCollisionWithCircle = function ( self, event )
		local phase = event.phase
		if phase == "began" then
			if self.name == "circle" and event.other.name == "enemy" then
	--			print("collision -circle -enemy")
				if id ~= nil then timer.cancel(id) end
				if id1 ~= nil then timer.cancel(id1) end
				event.other:removeSelf()
				self:removeSelf()
				count = 0
				bar = nil
				bar2 = nil
				Runtime:removeEventListener( "enterFrame", onPlace )
				Runtime:removeEventListener( "collision", circle )
				life = life - 1
				countText:removeSelf()
				turnStage()
			end
		end
	end

	shooting = function ( e )
		id = e.source
		local bullet
		local bulletPhysicsData
		bullet = display.newImage( "bullet/"..math.random(1,5)..".png" ,circle.x+circle.contentWidth*0.5, circle.y)
		bulletPhysicsData = (require "bullet.bullet").physicsData(1.0)
		physics.addBody( bullet, "dynamic", bulletPhysicsData:get("bullet"))
		bullet.gravityScale = 0
		bullet.isBullet = true
		bullet:setLinearVelocity( 1000, 0 )
		bullet.name = "bullet"
		bullet.collision = onLocalCollision
		bullet:addEventListener( "collision", bullet )
	end

	dropMonster = function ( e )
		id1 = e.source
		local num = math.random(1,5)
		local monsterString = "enemy/ene"..num..".png"
		monster = display.newImage( monsterString, _W, math.random(0,900)+120 )
		local monsterPhysicsData
		monster:scale(2.5,2.5)
		if num <= 3 then
			monsterPhysicsData = (require "enemy.ene1").physicsData(2.5)
			physics.addBody( monster, "dynamic", monsterPhysicsData:get("ene1"))
		else
			monsterPhysicsData = (require "enemy.ene2").physicsData(2.5)
			physics.addBody( monster, "dynamic", monsterPhysicsData:get("ene2"))
		end
		
		monster.gravityScale = 0
		monster:setLinearVelocity( -400, 0 )
		monster.name = "enemy"
	end

	--display.setDrawMode( "hybrid" )
	physics.setGravity(0,15)
	circle.collision = nil
	circle.collision = onLocalCollisionWithCircle
	circle:addEventListener( "collision", circle )

	local bar = display.newRect( 0, _H, _W, 20 )
	setAnchor(bar, 0, 0)
	physics.addBody(bar, "static", { bounce = 0 })
	
	local bar2 = display.newRect( 0, -20, _W, 20 )
	setAnchor(bar2, 0, 0)
	physics.addBody(bar2, "static", { bounce = 0 })


	Runtime:addEventListener( "enterFrame", onPlace )
	timer.performWithDelay( 250, shooting, -1 )
	timer.performWithDelay( 1500, dropMonster, -1 )
end

s02 = function( )
	local onPlace
	local moving
	local makePlanet
	local timeText = display.newText("Time : "..30, _W*0.8, _H*0.1, native.newFont("정9체.ttf"))
	timeText.size = 100

	local tag = nil

	onPlace = function ( e )
		if tag == nil then
			realTime = e.time
			tag = 1
		end
		circle.x = _W*0.3
		local time = 30 + realTime/1000 - e.time/1000
		timeText.text = "Time : "..time
		if time <= 0 then
			timeText:removeSelf()
			stageNum = stageNum + 1
			Runtime:removeEventListener( "enterFrame", onPlace )
			if id ~= nil then timer.cancel(id) end
			bar2 = nil
			bar = nil
			turnStage()

		end
	end

	onLocalCollision = function ( self, event )
		local phase = event.phase
		if phase == "began" then
			if self.name == "circle" and event.other.name == "planet" then
	--			print("collision -circle -planet")
				--gameOver
				timeText = nil
				event.other:removeSelf()
				life = life -1
				Runtime:removeEventListener( "enterFrame", onPlace )
				if id ~= nil then timer.cancel(id) end
				bar2 = nil
				bar = nil
				turnStage()
			end
		end
	end

	moving = function ( e, f, obj )
		print(obj)
		obj.x = obj.x - 10
	end

	makePlanet = function ( e )
		id = e.source
		local planet = {}
		local planetPhysicsData
 		local num = math.random(1,4)
		for i = 1, 5, 1 do
			if i == num or i == num+1 then
			else
				local num = math.random(1,3)
				planet[i] = display.newImage( "planet/"..num..".png", _W, _H*0.125 + 200*(i-1) )
				planet[i].name = "planet"
				physics.addBody( planet[i], "dynamic", { radius = 75 })
				planet[i].gravityScale = 0
				planet[i]:setLinearVelocity( -400, 0 )
			end
		end
	end

	physics.start( )
	--display.setDrawMode( "hybrid" )
	physics.setGravity( 0, 15 )
	circle.collision = onLocalCollision
	circle:addEventListener( "collision", circle )

	local bar = display.newRect( 0, _H, _W, 20 )
	setAnchor(bar, 0, 0)
	physics.addBody(bar, "static", { bounce = 0 })
	
	local bar2 = display.newRect( 0, -20, _W, 20 )
	setAnchor(bar2, 0, 0)
	physics.addBody(bar2, "static", { bounce = 0 })

	timer.performWithDelay( 2000, makePlanet, -1 )
	Runtime:addEventListener( "enterFrame", onPlace )
end

s03 = function( )
	local onPlace
	local dropRocket
	local onLocalCollision

	local maxRocket = 15
	local count = 0

	local id
	local countText = display.newText("rocket count : "..maxRocket, _W*0.78, _H*0.1, native.newFont("정9체.ttf"))
	countText.size = 100

	onPlace = function( e )
		circle.x = _W*0.3
	end

	onLocalCollision = function ( self, event )
		local phase = event.phase

		if phase == "began" then
			if self.name == "circle" and event.other.name == "rocket" then
	--			print("collision -circle -rocket")
				event.other:removeSelf()
				count = count + 1
				countText.text = "rocket count : "..maxRocket-count
				if count == maxRocket then
					--remove event&image
					timer.cancel(id)
					Runtime:removeEventListener( "enterFrame", onPlace )
					stageNum = stageNum + 1
					turnStage()
					countText:removeSelf()
				end
			end
		end

	end

	dropRocket = function ( e )
		id = e.source

 		local num = math.random(1,5)
 		local rocket = display.newImage("rocket.png", _W, _H*0.125 + 200*(num-1))
 		rocket.name = "rocket"
 		local rocketPhysicsData = (require "rocket").physicsData(0.75)
 		rocket:scale(0.75,0.75)
 		physics.addBody( rocket, "dynamic", rocketPhysicsData:get("rocket") )
 		rocket.gravityScale = 0
 		rocket.roatation = math.random( 0, 360 )
 		rocket:setLinearVelocity( -400, 0 )
	end


	circle.collision = onLocalCollision
	circle:addEventListener( "collision", circle )

	local bar = display.newRect( 0, _H, _W, 20 )
	setAnchor(bar, 0, 0)
	physics.addBody(bar, "static", { bounce = 0 })
	
	local bar2 = display.newRect( 0, -20, _W, 20 )
	setAnchor(bar2, 0, 0)
	physics.addBody(bar2, "static", { bounce = 0 })


	Runtime:addEventListener( "enterFrame", onPlace 
)	timer.performWithDelay( 1500, dropRocket, -1 )
end

s04 = function( )
	local onPlace
	local boss
	local bossFlow
	local onLocalCollision
	local onLocalCollisionwithBullet
	local id
	local bossHP = 100
	local bossText = display.newText("Boss HP : "..bossHP, _W*0.8, _H*0.1, native.newFont("정9체.ttf"))
	bossText.size = 100

	onPlace = function ( e )
		circle.x = _W*0.3
		boss.rotation = 0
	end

	onLocalCollision = function ( self, event )
		local phase = event.phase
		if phase == "began" then
			if self.name == "circle" and event.other.name == "enemy" then
	--			print("collision -circle -enemy")
				--gameOver
				timeText:removeSelf()
				life = life -1
				Runtime:removeEventListener( "enterFrame", onPlace )
				if id ~= nil then timer.cancel(id) end
				bar2 = nil
				bar = nil
				turnStage()
			elseif self.name == "circle" and event.other.name == "adogen" then
	--			print("collision =circle -adogen")
				timeText:removeSelf()
				life = life - 1
				Runtime:removeEventListener( "enterFrame", onPlace )
				if id ~= nil then timer.cancel(id) end
				bar2 = nil
				bar = nil
				turnStage()
			end
		end
	end

	onLocalCollisionwithBullet = function ( self, event )
		local phase = event.phase
		if phase == "began" then
			if self.name == "bullet" and event.other.name == "enemy" then
	--			print("collision -bullet -enemy")
				--gameOver
				timeText:removeSelf()
				event.other:removeSelf()
			end
			if self.name == "bullet" and event.other.name == "boss" then
	--			print("collision -bullet -boss")
				bossHP = bossHP - 1
				if bossHP <= 0 then
				elseif bossHP < 30 then
				elseif bossHP < 50 then
				elseif bossHP < 70 then
				elseif bossHP < 90 then
					bossPunch()
				end
				bossText.text = "Boss HP : "..bossHP
				self:removeSelf()
			end
		end
	end

	bossFlow = function ( e )
		id = e.source
		transition.to( boss, { y = _H*0.5 - 10, x = _W*0.85 - 7.5, time = 750 } )
		transition.to( boss, { y = _H*0.5, x = _W*0.85, time = 750, delay = 800 } )
	end

	bossPunch = function( e )
		local adogen = {}
		local adogenPhysicsData
		
		boss:setSequence( "attatck" )
		boss:play()

		for i = 1, 3, 1 do
	--		local adogen = display.newImage("bossBullet_dark.png")
			adogen[i] = display.newImage("bossBullet.png")
			adogen[i].name = "adogen"
			adogen[i]:scale(3.5,3.5)
			adogenPhysicsData = (require "adogen").physicsData(3.5)
			adogen[i].x, adogen[i].y = _W*0.8, _H*0.5
			physics.addBody( adogen[i], "dynamic", adogenPhysicsData:get("adogen"))
			adogen[i].gravityScale = 0
			adogen[i].isBullet = true
			--adogen[i]:setLinearVelocity( -800, 0 )
		end
	end

	shooting = function ( e )
		id1 = e.source
		local bullet
		local bulletPhysicsData
		bullet = display.newImage( "bullet/"..math.random(1,5)..".png" ,circle.x+circle.contentWidth*0.5, circle.y)
		physics.addBody( bullet, "dynamic", { radius = 25})
		bullet.gravityScale = 0
		bullet.isBullet = true
		bullet:setLinearVelocity( 800, 0 )
		bullet.name = "bullet"
		bullet.collision = onLocalCollisionwithBullet
		bullet:addEventListener( "collision", bullet )
	end

	local bossData = 
	{
		width = 800,
		height = 600,
		numFrames = 4,
		sheetContentWidth = 3200,
		sheetcontentHeight = 600, 
	}
	local bossSet = 
	{
		{ name = "normal", frames = { 1 }, time = 0, loopCount = 0 },
		{ name = "attack", frames = { 2,3 }, time = 300, loopCount = 3 },
		{ name = "die", frames = { 4 }, time = 0, loopCount = 0 },
	}

	local bossSheet = graphics.newImageSheet( "bossAttack.png", bossData )
	
	--display.setDrawMode( "hybrid" )
	physics.setGravity( 0, 15 )
	circle.collision = onLocalCollision
	circle:addEventListener( "collision", circle )

	boss = display.newSprite( bossSheet, bossSet )
	boss.name = "boss"
	bossPhysicsData = (require "boss").physicsData(0.75)
	physics.addBody(boss, "dynamic", bossPhysicsData:get("boss"))
	boss.gravityScale = 0
	boss.x, boss.y = _W*0.85, _H*0.5
	boss:scale(0.75,0.75)

	local bar = display.newRect( 0, _H, _W, 20 )
	setAnchor(bar, 0, 0)
	physics.addBody(bar, "static", { bounce = 0 })
	
	local bar2 = display.newRect( 0, -20, _W, 20 )
	setAnchor(bar2, 0, 0)
	physics.addBody(bar2, "static", { bounce = 0 })

	Runtime:addEventListener( "enterFrame", onPlace )
	timer.performWithDelay( 1600, bossFlow, -1 )
	timer.performWithDelay( 330, shooting, -1 )
end
--connect servWer plz.
--local b = connectToServer("192.168.255.80", 11000)
--print(type(b))
--createClientLoop( connectToServer("192.168.255.80", 11000 ) "192.168.255.80", 11000 )
--turnStage()
--display.setDrawMode("hybrid")
--s03()
--connectToServer("192.168.255.80",11000)
--createClientLoop( connectToServer("192.168.255.80", 11000), "192.168.255.80", 11000 )
physics.start()
circle = display.newCircle(_W*0.3, _H*0.5, 100, 100)
circle.name = "circle"
physics.addBody(circle, "dynamic", { bounce = 0, radius = 100 })
circle.gravityScale = 0
circle:setFillColor(CC("888888"))
circle.alpha = 0.3


Runtime:addEventListener( "enterFrame",  ball )
turnStage()

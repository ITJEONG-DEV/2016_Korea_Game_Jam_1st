math.randomseed( os.time( ) )

local physics = require "physics"
local json = require "json"

local _W, _H = display.contentWidth, display.contentHeight

local CC = function( hex )
	local r = tonumber( hex:sub( 1, 2 ), 16 ) / 255
	local g = tonumber( hex:sub( 3, 4 ), 16 ) / 255
	local b = tonumber( hex:sub( 5, 6 ), 16 ) / 255
	local a = 255 / 255
	if #hex == 8 then a = tonumber( ehx:sub( 7, 8 ), 16 ) end
	return r, g, b, a
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

local loadData = function( )
	local path = ''

	local file, errorString = io.open( path, 'r' )

	if not file then
		print( 'File error : ' .. errorString )
	else
		local decoded, pos, msg = json.decodedFile( path )

		if not decoded then
			print( 'decode failed at' .. tostring(pos) .. ': ' .. tostring(msg) )
		else
			heightMax = decoded.heightMax
			heightMin = decoded.heightMin
			heightNow = decoded.ehgithNow
		end

		io.close( file )
	end

	file = nil
end

local ball = function( )
	localData()
	circle.x, circle.y = _W*0.3, heightNow / heightMin * 1080
end

turnStage = function( )
	local goStage
	local textTimer
	local bg
	local box
	local lifeI = { }
	local id
	goStage = function( )
		Runtime:removeEventListener( "touch", goStage )
		if id ~= nil then timer.cancel( id ) end
		if life == 0 then stageNum = -1
		else
			for i = 1, life, 1 do
				lifeI[i]:removeSelf( )
			end
		end
		box:removeSelf( )
		bg:removeSelf( )

		if stageNum == -1 then s00( )
		elseif stageNum == 1 then s01( )
		elseif stageNum == 2 then s02( )
		elseif stageNum == 3 then s03( )
		elseif stageNum == 4 then s04( )
		end
	end

	textTimer = function( e )
		id = e.source
		if box.alpha == 1 then box.alpha = 0
			else box.alpha = 1
		end
	end

	if stageNum < 0 then
		bg = display.newImage( "over.png", 0, 0 )
	else
		bg = display.newImage( "stage/"..stageNum..".png", 0, _H*0.55 )

		for i = 1, life, 1 do
			lifeI[i] = display.newImage( "life.png", _W*0.454+100*(i-1), _H*0.29 )
		end
	end
	bg.anchorX, bg.anchorY = 0, 0

	circle:removeEventListener( "collision", circle )
	circle:removeSelf()
	circle = display.newCircle( _W*0.3, _H*0.5, 100, 100 )
	circle.name = "circle"
	physics.addBody( circle, "dynamic", { bounce = 0, radius = 100 } )
	circle.gravityScale = 0
	--circle:setFillColor( CC( "999999") )
	circle:setFillColor( CC( "333333") )
	circle.alpha = 0.3
	box = display.newRect( _W * 0.5, _H * 0.68, _W*0.4, 70 )
	box:setFillColor( CC("000000") )
	box.alpha = 0

	timer.performWithDelay( 650, textTimer, -1 )
	Runtime:addEventListener( "touch", goStage )
end

s01 = function( )
	local monster
	local shooting
	local dropMonster
	local localCollisionWithMonster
	local localCollisionWithCircle

	local id
	local id1

	local maxCount = 25
	local count = 0
	local countText = display.newText( "enemy count : " .. maxCount, _W*0.78, _H*0.1, native.newFont("정9체.ttf") )
	countText.size = 100

	localCollisionWithMonster = function( self, event )
		local phase = event.phase

		if phase == "began" then
			if self.name == "bullet" and event.other.anme == "enemy" then
				event.other:removeSelf()
				self:removeSelf()
				count = coutn + 1
				countText.text = "enemy count : " .. ( maxCount - count )
				if count == maxCount then
					if id ~= nil then timer.cancel( id ) end
					if id1 ~= nil then timer.cancel( id1 ) end
					Runtime:removeEventListener( "collision", circle )
					stageNum = stageNum + 1
					countText:removeSelf()
					turnStage()
				end
			end
		end
	end

	localCollisionWithCircle = function( self, event )
		local phase = event.phase

		if phase == "began" then
			if self.name == "circle" and evnet.other.name == "enemy" then
				if id ~= nil then timer.cancel( id ) end
				if id1 ~= nil then timer.cancel( id1 ) end
				event.other:removeSelf()
				self:removeSelf()
				count = 0
				Runtime:removeEventListener( "collision", circle )
				life = life - 1
				countText:removeSelf()
				turnStage()
			end
		end
	end

	shooting = function( e )
		id = e.source
		local bullet
		local bulletPhysicsData
		bullet = display.newImage( "bullet/" .. math.random(1,5) .. ".png", circle.x-circle.contentWidgh*0.5, circle.y )
		bulletPhysicsData = ( require "bullet.bullet" ).physicsData(1.0)
		physics.addBody( bullet, "dynamic", bulletPhysicsData:get("bullet") )
		bullet.gravityScale = 0
		bullet.isBullet = true
		bullet.setLinearVelocity( 1000, 0 )
		bullet.name = "bullet"
		bullet.collision = localCollisionWithMonster
		bullet:addEventListener( "collision", bullet )
	end

	dropMonster = function( e )
		id1 = e.source
		local num = math.random(1,5)
		local monsterString = "enemy/ene"..num..".png"
		local monsterPhysicsData
		monster = display.newImage( monsterString, _W, math.random(0,900)+120 )
		monster:scale(2.5, 2.5)
		if num <= 3 then
			monsterPhysicsData = (require "enemy.ene1").physicsData(2.5)
			physics.addBody( monster, "dynamic", monsterPhysicsData:get("ene1") )
		else
			monsterPHysicsData = (require "enemy.ene2").physicsData(2.5)
			physics.addBody( monster, "dynamic", monsterPhysicsData:get("ene2") )
		end

		monster.gravityScale = 0
		monster:setLinearelocity( -400, 0 )
		monster.name = "enemy"
	end	

	physics.setGravity( 0, 15 )
	circle.collisoin = nil
	circle.colision = localCollisionWithCircle
	circle:addEventListener( "collision", ciecle )
	timer.performWithDelay( 250, shooting, -1 )
	timer.performWithDelay( 1500, dropMonster, -1 )
end


s02 = function( )
	local moving
	local makePlanet
	local localCollisionWithPlanet
	local timeText = display.newText( "Time : " .. 30, _W*0.8, _H*0.1, native.newFont("정9체.ttf") )
	timeText.sie = 100

	local tag = nil

	localCollisionWithPlanet = function( self, event )
		local phase == event.phase
		if phase == "began" then`
			if self.name == "circle" and event.other.name == "planet" then
				timeText:removeSelf()
				event.other:removeSelf()
				life = life - 1
				Runtime:removeEventListener( "enterFrame", onPlace )
				if id ~= nil then timer.cancel(id) end
				turnStage()
			end
		end
	end

	moving = function( e, f, obj )
		print(obj)
		obj.x = obj.x -10
	end

	makePlanet = function( e )
		id = e.source
		local planet = {}
		local planetPhysicsData
		local num = math.random(1,4)
		for i = 1, 5, 1 do
			if i == num or i == num+1 then
			else
				local num = math.random(1,3)
				planet[i] = display.newImage( "planet/" .. num .. ".png", _W, _H*0.125 + 200*(i-1) )
				planet[i].name = "planet"
				physics.addBody( planet[i], "dynamic", { radius = 75 } )
				planet[i].gravityScale = 0
				planet[i]:setLinearVelocity( -400, 0 )
			end
		end
	end

	physics.setGravity( 0, 15 )
end

circle = display.newCircle( _W*0.3, _H*0.5, 100, 100 )
circle.name = "circle"
physics.addBody( circle, "dynamic", { bounce = 0, radius = 100 } )
circle.gravityScale = 0
--circle:setFillColor( CC( "999999") )
circle:setFillColor( CC( "333333") )
circle.alpha = 0.3

bar = display.newRect( 0, _H, _W, 20 )
bar.x, bar.y = 0, 0
physics.addBody( bar, "static", { bounce = 0 } )

bar2 = display.newRect( 0, -20, _W, 20 )
bar2.x, bar2.y = 0, 0
physics.addBody( bar2, "static", { boucne = 0 } )

Runtime:addEventListener( "enterFrame", ball )











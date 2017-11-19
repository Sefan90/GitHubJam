
local sti = require "sti"
local bump = require "bump"
local temp = ""

function love.load()
	world = bump.newWorld()
	map = sti("levels/level5.lua", {"bump"})
	map:bump_init(world)

	player = {
		name = 'player',
		x = 32,
		y = 32,
		w = 12,
		h = 12,
		speed = 120
	}
	world:add(player,player.x,player.y,player.w,player.h)

	box = {
		name = 'box',
		x = 64,
		y = 64,
		w = 12,
		h = 12
	}
	world:add(box,box.x,box.y,box.w,box.h)

	doors = {{name = "door1", x = 128, standardx = 128, y = 128, standardy = 128, w = 12, h = 12, active = false}}
	world:add(doors[1],doors[1].x,doors[1].y,doors[1].w,doors[1].h)

	buttons = {{name = "buttondoor1", x = 128, y = 150, w = 12, h = 12, active = false}}
	world:add(buttons[1],buttons[1].x,buttons[1].y,buttons[1].w,buttons[1].h)
end

function love.update(dt)
	map:update(dt)
	if love.keyboard.isDown('right','d') then
		moveplayer(player.speed,0,dt)
		--local actualX, actualY, cols, len = world:move('player',player.x+player.speed*dt,player.y,playerFilter)
        --player.x, player.y = actualX, actualY
	elseif love.keyboard.isDown('left','a') then
		moveplayer(-player.speed,0,dt)
		--local actualX, actualY, cols, len = world:move('player',player.x-player.speed*dt,player.y,playerFilter)
        --player.x, player.y = actualX, actualY
	elseif love.keyboard.isDown('down','s') then
		moveplayer(0,player.speed,dt)
		--local actualX, actualY, cols, len = world:move('player',player.x,player.y+player.speed*dt,playerFilter)
        --player.x, player.y = actualX, actualY
	elseif love.keyboard.isDown('up','w') then
		moveplayer(0,-player.speed,dt)
		--local actualX, actualY, cols, len = world:move('player',player.x,player.y-player.speed*dt,playerFilter)
        --player.x, player.y = actualX, actualY
	end
	checkbutton()
	checkdoor()
end

function love.draw()
	map:draw(dt)
	love.graphics.rectangle('fill', player.x, player.y, player.w, player.h)
	love.graphics.rectangle('fill', box.x, box.y, box.w, box.h)
	love.graphics.rectangle('fill', doors[1].x, doors[1].y, doors[1].w, doors[1].h)
	love.graphics.rectangle('fill', buttons[1].x, buttons[1].y, buttons[1].w, buttons[1].h)
	--love.graphics.print(player.x..player.y,16,16)
	love.graphics.print(temp,16,16)
end

function moveplayer(x,y,dt) 
	local actualX, actualY, cols, len = world:check(player,player.x+x*dt,player.y+y*dt,playerFilter)
	for i=1,len do
		if cols[i].other.name ~= nil then
			if string.find(cols[i].other.name,"box") then 
				local actualXbox, actualYbox, colsbox, lenbox = world:move(cols[i].other,cols[i].other.x+x*dt,cols[i].other.y+y*dt,playerFilter)
				cols[i].other.x, cols[i].other.y = actualXbox, actualYbox
			end 
		end
	end 
	local actualX, actualY, cols, len = world:move(player,player.x+x*dt,player.y+y*dt,playerFilter)
	player.x, player.y = actualX, actualY
end

function checkbutton() 
	for i = 1, #buttons do 
		actualX, actualY, cols, len = world:check(buttons[i],buttons[i].x,buttons[i].y,playerFilter) 
		if len > 0 then 
			temp = tostring(cols[i].other.name)
			buttons[i].active = true 
		else 
			buttons[i].active = false 
		end 
	end 
end 

function checkdoor() 
	for i = 1, #doors do 
		doors[i].active = true 
		for j = 1, #buttons do 
			if string.find(buttons[j].name,doors[i].name) and buttons[j].active == false then 
				doors[i].active = false 
				break 
			end 
		end 
		if doors[i].active == false then 
			world:update(doors[i],doors[i].standardx,doors[i].standardy,doors[i].w,doors[i].h)
			doors[i].x, doors[i].y = doors[i].standardx, doors[i].standardy
		else 
			world:update(doors[i],0,0,doors[i].w,doors[i].h) 
			doors[i].x, doors[i].y = 0,0
		end 
	end 
end

function camera(player)
	if player.x < camera.x then
		camera.x = camera.x - 160
	elseif player.x > camera.x+160 then
		camera.x = camera.x + 160
	elseif player.y < camera.y then
		camera.y = camera.y - 160
	elseif player.y > camera.y+160 then
		camera.y = camera.y + 160
	end
end

playerFilter = function(item, other)
	if item.name ~= nil and other.name ~= nil then
		if string.find(other.name,"button") and (string.find(item.name,"player") or string.find(item.name,"box")) then
			return "cross"
		end
	end
	return "touch"
end


local game = {}

game.player1 = nil
game.player2 = nil
game.ball = nil

game.playerXPadding = 40
game.playerThickness = 20
game.playerSpeed = 200

game.playerID = 1

function game.onStateLoad()
	local width, height = love.graphics.getDimensions()

	game.player1 = {size=100,y=height/2-35}
	game.player2 = {size=100,y=height/2-35}

	game.ball = {size=20,speed=100}
	game.ball.pos = vec2.new(width/2-game.ball.size/2, height/2-game.ball.size/2)
	game.ball.vel = vec2.new(0, 0)
	game.start()
end

function game.draw()
	local width, height = love.graphics.getDimensions()
	love.graphics.rectangle("fill", game.playerXPadding-game.playerThickness/2, game.player1.y-game.player1.size/2, game.playerThickness, game.player1.size)
	love.graphics.rectangle("fill", width-game.playerXPadding-game.playerThickness/2, game.player2.y-game.player2.size/2, game.playerThickness, game.player2.size)
	love.graphics.rectangle("fill", game.ball.pos.x-game.ball.size/2, game.ball.pos.y-game.ball.size/2, game.ball.size, game.ball.size)
end

function game.update(dt)
	local width, height = love.graphics.getDimensions()

	local moveAmount = 0
	if love.keyboard.isDown("up") then moveAmount = -game.playerSpeed*dt end
	if love.keyboard.isDown("down") then moveAmount = game.playerSpeed*dt end
	
	local player = nil
	if game.playerID == 1 then
		player = game.player1
	elseif game.playerID == 2 then
		player = game.player2
	end

	player.y = player.y + moveAmount

	if player.y-player.size/2 < 0 then player.y = player.size/2 end
	if player.y+player.size/2 > height then player.y = height-player.size/2 end

	net.set("pos", player.y)

	game.ball.pos = game.ball.pos:add(game.ball.vel:mul(game.ball.speed*dt))
	net.set("ballpos", {game.ball.pos.x, game.ball.pos.y})
end

function game.start()
	game.ball.vel:setXY((math.random(0, 1)-0.5)*2, (math.random(0, 1)-0.5)*2)
end

return game
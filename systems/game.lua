local game = {}

game.players = {}

game.myID = 1

game.paddlePadding = 10
game.paddleDepth = 10
game.paddleLength = 100

game.paddleSpeed = 500

game.scorePadding = 50

game.ball = nil
game.ballSize = 10
game.ballSpeed = 300

game.blipEffect = nil

function game.onStateLoad()
	game.blipEffect = love.audio.newSource("/assets/audio/pongBlip2.wav", "static")
	game.addPlayer()
	game.startGame()
end

local negative = function(a)
	return (a>0) and -a or a
end

local positive = function(a)
	return (a<0) and -a or a
end

function game.update(dt)
	local width, height = love.graphics.getDimensions()
	if game.myID > 0 and game.myID < 5 then
		-- local player = game.players[game.myID]
		-- local moveAmount = 0
		-- if game.myID == 1 or game.myID == 2 then
		-- 	moveAmount = love.keyboard.isDown("up") and -1 or 0
		-- 	moveAmount = love.keyboard.isDown("down") and 1 or moveAmount
		-- else
		-- 	moveAmount = love.keyboard.isDown("left") and -1 or 0
		-- 	moveAmount = love.keyboard.isDown("right") and 1 or moveAmount
		-- end

		-- if player then
		-- 	player.pos = player.pos + moveAmount*game.paddleSpeed*dt
		-- 	if player.pos-game.paddleLength/2 < 0 then player.pos = game.paddleLength/2 end
		-- 	if player.pos+game.paddleLength/2 > width then player.pos = width-game.paddleLength/2 end
		-- end

		for i=1, 2 do
			local player = game.players[i]

			local moveAmount = 0
			moveAmount = love.keyboard.isDown("up") and -1 or 0
			moveAmount = love.keyboard.isDown("down") and 1 or moveAmount

			if player then
				player.pos = player.pos + moveAmount*game.paddleSpeed*dt
				if player.pos-game.paddleLength/2 < 0 then player.pos = game.paddleLength/2 end
				if player.pos+game.paddleLength/2 > width then player.pos = width-game.paddleLength/2 end
			end
		end
	end

	if game.ball then
		game.ball.pos = game.ball.pos:add(game.ball.vel:mul(game.ballSpeed):mul(dt))

		local bx, by = game.ball.pos:xy()
		if bx+game.ballSize/2 < 0 or bx-game.ballSize/2 > width or by+game.ballSize/2 < 0 or by-game.ballSize/2 > height then game.endGame() end

		local player = game.players[1]
		if player then
			if bx-game.ballSize/2 < game.paddlePadding+game.paddleDepth and by-game.ballSize/2 < player.pos+game.paddleLength/2 and by+game.ballSize/2 > player.pos-game.paddleLength/2 then
				game.ball.vel.x = positive(game.ball.vel.x)
				local ratio = (game.ball.pos.y-player.pos)/(game.paddleLength/4)
				game.ball.vel.y = ratio
				game.playSound()
			end
			if bx+game.ballSize/2 < 0 then game.endGame() end
		else
			if bx-game.ballSize/2 < 0 then
				game.ball.vel.x = positive(game.ball.vel.x)
				game.playSound()
			end
		end

		player = game.players[2]
		if player then
			if bx+game.ballSize/2 > width-game.paddlePadding-game.paddleDepth and by-game.ballSize/2 < player.pos+game.paddleLength/2 and by+game.ballSize/2 > player.pos-game.paddleLength/2 then
				game.ball.vel.x = negative(game.ball.vel.x)
				local ratio = (game.ball.pos.y-player.pos)/(game.paddleLength/4)
				game.ball.vel.y = ratio
				game.playSound()
			end
			if bx-game.ballSize/2 > width then game.endGame() end
		else
			if bx+game.ballSize/2 > width then
				game.ball.vel.x = negative(game.ball.vel.x)
				game.playSound()
			end
		end

		if by-game.ballSize/2 < 0 then
			game.ball.vel.y = positive(game.ball.vel.y)
			game.playSound()
		end

		if by+game.ballSize/2 > height then
			game.ball.vel.y = negative(game.ball.vel.y)
			game.playSound()
		end
	end
end

function game.draw()
	local width, height = love.graphics.getDimensions()
	local player = game.players[1]
	if player then
		love.graphics.print(player.score, width/2-game.scorePadding, game.scorePadding)
		love.graphics.rectangle("fill", game.paddlePadding, player.pos-game.paddleLength/2, game.paddleDepth, game.paddleLength)
	end

	player = game.players[2]
	if player then
		love.graphics.print(player.score, width/2+game.scorePadding, game.scorePadding)
		love.graphics.rectangle("fill", width-game.paddlePadding-game.paddleDepth, player.pos-game.paddleLength/2, game.paddleDepth, game.paddleLength)
	end

	if game.ball then
		love.graphics.rectangle("fill", game.ball.pos.x-game.ballSize/2, game.ball.pos.y-game.ballSize/2, game.ballSize, game.ballSize)
	end

	love.graphics.setLineStyle("rough")
	local indices = 50
	for i=0, (indices/2)-1 do
		love.graphics.line(width/2, i*((height/2)/indices*2)*2, width/2, (i+0.75)*((height/2)/indices*2)*2)
	end


end

function game.keypressed(key)
	if key == " " then
		game.addPlayer()
	elseif key == "f" then
		game.removePlayer(#game.players)
	end
end

function game.playSound()
	game.blipEffect:play()
end

function game.addPlayer()
	if #game.players < 2 then
		local width, height = love.graphics.getDimensions()
		table.insert(game.players, {pos=width/2,score=0})
	end
end

function game.removePlayer(id)
	if id > 0 and id < 3 then
		table.remove(game.players, id)
	end
end

function game.startGame()
	local width, height = love.graphics.getDimensions()
	game.ball = {pos=vec2.new(width/2, height/2),vel=vec2.new((math.random(0, 1)-0.5)*2, (math.random(0, 1)-0.5)*2)}
end

function game.endGame()
	-- love.event.quit()
	game.startGame()
end

return game
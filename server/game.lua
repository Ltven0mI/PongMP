local game = {}

game.players = {}

game.paddlePadding = 10
game.paddleDepth = 10
game.paddleLength = 100

game.paddleSpeed = 700

game.ball = nil
game.ballSize = 10
game.ballSpeed = 300

local negative = function(a)
	return (a>0) and -a or a
end

local positive = function(a)
	return (a<0) and -a or a
end

function game.update(dt)
	local width, height = 700, 700

	for i=1,2 do
		local player = net.players[game.players[i]]

		if player then
			if player.pos-game.paddleLength/2 < 0 then player.pos = game.paddleLength/2 end
			if player.pos+game.paddleLength/2 > width then player.pos = width-game.paddleLength/2 end
			net.setAll("player_"..i.."_pos", math.floor(player.pos))
		end
	end

	if game.ball then
		game.ball.pos = game.ball.pos:add(game.ball.vel:mul(game.ballSpeed):mul(dt))

		local bx, by = game.ball.pos:xy()

		local player = net.players[game.players[1]]
		if player then
			if bx-game.ballSize/2 < game.paddlePadding+game.paddleDepth and by-game.ballSize/2 < player.pos+game.paddleLength/2 and by+game.ballSize/2 > player.pos-game.paddleLength/2 then
				game.ball.vel.x = positive(game.ball.vel.x)
				local ratio = (game.ball.pos.y-player.pos)/(game.paddleLength/4)
				game.ball.vel.y = ratio
				game.ball.pos.x = game.paddlePadding+game.paddleDepth+game.ballSize/2
				net.playSound("beep")
			end
			if bx+game.ballSize/2 < 0 then game.endGame(1) end
		else
			if bx-game.ballSize/2 < 0 then
				game.ball.vel.x = positive(game.ball.vel.x)
				game.ball.pos.x = game.ballSize/2
				net.playSound("beep")
			end
		end

		player = net.players[game.players[2]]
		if player then
			if bx+game.ballSize/2 > width-game.paddlePadding-game.paddleDepth and by-game.ballSize/2 < player.pos+game.paddleLength/2 and by+game.ballSize/2 > player.pos-game.paddleLength/2 then
				game.ball.vel.x = negative(game.ball.vel.x)
				local ratio = (game.ball.pos.y-player.pos)/(game.paddleLength/4)
				game.ball.vel.y = ratio
				game.ball.pos.x = width-game.paddlePadding-game.paddleDepth-game.ballSize/2
				net.playSound("beep")
			end
			if bx-game.ballSize/2 > width then game.endGame(2) end
		else
			if bx+game.ballSize/2 > width then
				game.ball.vel.x = negative(game.ball.vel.x)
				game.ball.pos.x = width-game.ballSize/2
				net.playSound("beep")
			end
		end

		if by-game.ballSize/2 < 0 then
			game.ball.vel.y = positive(game.ball.vel.y)
			net.playSound("beep")
		end

		if by+game.ballSize/2 > height then
			game.ball.vel.y = negative(game.ball.vel.y)
			net.playSound("beep")
		end
		net.setAll("ball", {math.floor(game.ball.pos.x), math.floor(game.ball.pos.y)})
	end
end

function game.draw()
	local scale = 300/700
	local width, height = 300, 300
	if game.ball then
		love.graphics.rectangle("fill", (game.ball.pos.x-5)*scale, (game.ball.pos.y-5)*scale, 10, 10)
	end

	local player = net.players[game.players[1]]
	if player then
		love.graphics.rectangle("fill", game.paddlePadding*scale, (player.pos-game.paddleLength/2)*scale, game.paddleDepth*scale, game.paddleLength*scale)
	end

	local player = net.players[game.players[2]]
	if player then
		love.graphics.rectangle("fill", width-(game.paddlePadding+game.paddleDepth)*scale, (player.pos-game.paddleLength/2)*scale, game.paddleDepth*scale, game.paddleLength*scale)
	end
end

function game.addPlayer(nick)
	local function resetScores()
		if game.players[1] then
			net.players[game.players[1]].score = 0
			net.setAll("player_1_score", 0)
		end
		if game.players[2] then
			net.players[game.players[2]].score = 0
			net.setAll("player_2_score", 0)
		end
	end

	if not game.players[1] then
		game.players[1] = nick
		resetScores()
		return 1
	elseif not game.players[2] then
		game.players[2] = nick
		resetScores()
		return 2
	end
	return 3
end

function game.removePlayer(id)
	if id > 0 and id < 3 then
		table.remove(game.players, id)
	end
end

function game.startGame()
	local width, height = 700, 700
	game.ball = {pos=vec2.new(width/2, height/2),vel=vec2.new((math.random(0, 1)-0.5)*2, (math.random(0, 1)-0.5)*2)}
	net.newGame()
end

function game.endGame(playerID)
	if playerID == 1 then
		local player = net.players[game.players[2]]
		if player then 
			player.score = player.score + 1
			net.setAll("player_2_score", player.score)
		end
	elseif playerID == 2 then
		local player = net.players[game.players[1]]
		if player then 
			player.score = player.score + 1
			net.setAll("player_1_score", player.score)
		end
	end
	if net.online > 0 then game.startGame() else game.ball = nil end
end

return game
local game = {}

game.players = {}

game.myID = 1

game.paddlePadding = 10
game.paddleDepth = 10
game.paddleLength = 100

game.paddleSpeed = 700

game.scorePadding = 50
game.scoreFont = nil
game.scoreScale = 5

game.ball = nil
game.ballSize = 10
game.ballSpeed = 300

game.blipEffects = {}
game.lineWidth = 5

function game.onStateLoad()
	game.scoreFont = love.graphics.newImageFont("/assets/images/fontGlyphs.png", "1234567890")
	love.graphics.setFont(game.scoreFont)
	game.blipEffects[1] = love.audio.newSource("/assets/audio/pongBlip2.wav", "static")
	game.blipEffects[2] = love.audio.newSource("/assets/audio/pongBlip2.wav", "static")
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
	if game.myID > 0 and game.myID < 3 then
		local player = game.players[game.myID]

		local moveAmount = 0
		moveAmount = love.keyboard.isDown("up") and -1 or 0
		moveAmount = love.keyboard.isDown("down") and 1 or moveAmount

		if player then
			player.pos = player.pos + moveAmount*game.paddleSpeed*dt
			if player.pos-game.paddleLength/2 < 0 then player.pos = game.paddleLength/2 end
			if player.pos+game.paddleLength/2 > width then player.pos = width-game.paddleLength/2 end
			net.set("player_pos",math.floor(player.pos))
		end
	end
end

function game.draw()
	love.graphics.setColor(255, 255, 255, 255)
	local width, height = love.graphics.getDimensions()
	local player = game.players[1]
	if player then
		love.graphics.print(net.playerOneScore, math.floor(width/2-game.scorePadding-game.scoreFont:getWidth(player.score)*game.scoreScale/2), math.floor(game.scorePadding), 0, game.scoreScale)
		if game.myID == 1 then
			love.graphics.rectangle("fill", game.paddlePadding, game.getAvg(net.playerOnePos, player.pos)-game.paddleLength/2, game.paddleDepth, game.paddleLength)
		else
			love.graphics.rectangle("fill", game.paddlePadding, net.playerOnePos-game.paddleLength/2, game.paddleDepth, game.paddleLength)
		end
	end

	player = game.players[2]
	if player then
		love.graphics.print(net.playerTwoScore, math.floor(width/2+game.scorePadding-game.scoreFont:getWidth(player.score)*game.scoreScale/2)+0.5, math.floor(game.scorePadding)+0.5, 0, game.scoreScale)
		if game.myID == 2 then
			love.graphics.rectangle("fill", width-game.paddlePadding-game.paddleDepth, game.getAvg(net.playerTwoPos, player.pos)-game.paddleLength/2, game.paddleDepth, game.paddleLength)
		else
			love.graphics.rectangle("fill", width-game.paddlePadding-game.paddleDepth, net.playerTwoPos-game.paddleLength/2, game.paddleDepth, game.paddleLength)
		end
	end

	if game.ball then
		love.graphics.rectangle("fill", game.ball.pos.x-game.ballSize/2, game.ball.pos.y-game.ballSize/2, game.ballSize, game.ballSize)
	end

	love.graphics.setLineStyle("rough")
	local lineWidth = love.graphics.getLineWidth()
	local indices = 50
	love.graphics.setLineWidth(game.lineWidth)
	for i=0, (indices/2)-1 do
		love.graphics.line(width/2, i*((height/2)/indices*2)*2, width/2, (i+0.75)*((height/2)/indices*2)*2)
	end
	love.graphics.setLineWidth(lineWidth)
end

function game.getAvg(a,b) return (a+b)/2 end

function game.playSound()
	if game.blipEffects[1]:isPlaying() then
		game.blipEffects[2]:play()
	else
		if not game.blipEffects[2]:isPlaying() then
			game.blipEffects[1]:play()
		end
	end
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
	net.playerOnePos = width/2
	net.playerTwoPos = width/2
	if game.players[1] then game.players[1].pos = width/2 end
	if game.players[2] then game.players[2].pos = width/2 end
end

return game
local game = {}
game.player = {}
game.player.pos = vec2.new(50,0)

function game.draw()
	love.graphics.rectangle("fill", game.player.pos.x, game.player.pos.y, 100, 100)
end

function game.update(dt)
	if love.keyboard.isDown("up") then
		game.player.pos.y = game.player.pos.y - 100 * dt
	end
	if love.keyboard.isDown("down") then
		game.player.pos.y = game.player.pos.y + 100 * dt
	end
	net.set("pos",game.player.pos.y)
end

return game
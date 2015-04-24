io.stdout:setvbuf("no")
love.window.setMode(300, 300, {})
love.window.setTitle("PongMP - Server")

advMath = require("libraries.advMath")
game = require("game")

net = {}
net.udp = require("socket").udp()
net.udp:settimeout(0)
net.udp:setsockname('*', 27014)


net.timeout = 15
net.rate = 33

net.online = 0
net.lastNetworkVariables = {}
net.networkVariables = {}
net.rateTimer = 0
net.players = {}

function love.draw()
	game.draw()
end

function love.update(dt)
	game.update(dt)

	local packet, ip, port = net.udp:receivefrom()
	if packet then
		local data = deserialize(packet)
		if data.job == "connect" then
			if not net.players[data.nick] then
				net.players[data.nick] = {
					nick = data.nick,
					ip = ip,
					port = port,
					pos = 350,
					score = 0,
					timeout = net.timeout,
					id = table.getn(net.players)+1,
					paddleId = 0,
				}
				if table.getn(net.players) < 3 then
					net.players[data.nick]["paddleId"] = game.addPlayer(data.nick)
				end
				if table.getn(net.players) < 2 then
					game.startGame()
				end
				net.online = net.online + 1
				-- table.insert(net.players, newPlayer)
				net.udp:sendto(serialize({job="connect", status="done", playing=net.online, pid = net.players[data.nick]["paddleId"]}),ip,port)
				net.joined(data.nick)
				net.lastNetworkVariables = {}
				print(data.nick.." connected!")
			else
				net.udp:sendto(serialize({job="connect", status="failed"}),ip,port)
			end
		elseif data.job == "update" then
			timeoutReset(net.players[data.nick])
			if data.name == "player_pos" then
				net.players[data.nick]["pos"] = data.value
			end
		elseif data.job == "keepAlive" then
			timeoutReset(net.players[data.nick])

		elseif data.job == "disconnect" then
			clientDisconnect(net.players[data.nick])
		end
	end

	net.rateTimer = net.rateTimer + dt
	if net.rateTimer >= 1/net.rate then
		net.rateTimer = 0
		for netVar,value in pairs(net.networkVariables) do
			if value then
				if value ~= net.lastNetworkVariables[netVar] then
					net.lastNetworkVariables[netVar] = value
					for nick,player in pairs(net.players) do
						net.udp:sendto(serialize(structUpdatePacket(netVar,value)),player.ip,player.port)
					end
				end
			end
		end
	end

	for nick,player in pairs(net.players) do
		if player.timeout < 0 then
			clientDisconnect(player, true)
			print(nick.." timed out!")
		else
			player.timeout = player.timeout - dt;
		end
	end
end

function net.newGame()
	for nick,player in pairs(net.players) do
		net.udp:sendto(serialize({job="newGame"}),player.ip,player.port)
	end
end

function net.joined(joinedNick)
	for nick,player in pairs(net.players) do
		net.udp:sendto(serialize({job="joined", newPlayerNick=joinedNick, playing=table.getn(net.players)}),player.ip,player.port)
	end
end
function net.left(leftPlayer)
	for nick,player in pairs(net.players) do
		net.udp:sendto(serialize({job="left", paddleId=leftPlayer.paddleId}),player.ip,player.port)
	end
end

function net.playSound(sound)
	for nick,player in pairs(net.players) do
		net.udp:sendto(serialize({job="sound", sound=sound}),player.ip,player.port)
	end
end

function net.setAll(netVar,value)
	net.networkVariables[netVar] = value
end

function clientDisconnect(player, wasTimeout)
	net.players[player.nick] = nil
	game.players[player.paddleId] = nil
	net.online = net.online - 1
	if not wasTimeout then
		net.udp:sendto(serialize({job="disconnect",status="done"}),player.ip,player.port)
	end
	net.left(player)
	game.endGame()
end

function timeoutReset(player)
	player.timeout = net.timeout
end

function structUpdatePacket(varName,value)
	return {
		job = "update",
		name = varName,
		value = value,
	}
end

function serialize(t)
	local str = "{"
		for key, val in pairs(t) do
			if type(key) == "number" then key = "" else key = key .. "=" end
			if str ~= "{" then str = str.."," end
			if type(val) ~= "table" then
				local varStr = tostring(val)
				if type(val) == "string" then varStr = "'"..val.."'" end
				str = str..key..varStr
			else
				str = str..key..serialize(val)
			end
		end
	return str.."}"
end

function deserialize(s)
	return assert(loadstring("return "..s))()
end

function sequence(current,last,max)
	if current > last and (current - last) <= max/2 
		or last > current and (last - current) > max/2 then return true end
end
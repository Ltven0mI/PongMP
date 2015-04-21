-- setup and declare variables --
local net = {}
net.udp = require("socket").udp()

net.rate = 24
net.nick = "Player"
net.id = 0

net.playerOnePos = 0
net.playerTwoPos = 0
net.playerOneScore = 0
net.playerTwoScore = 0
net.networkVariables = {}
net.lastNetworkVariables = {}
net.rateTimer = 0
net.keepAliveTimer = 0
net.status = "idle"
net.sequence_local = 1
net.sequence_host = 1

-- local functions --
local function serialize(t)
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

local function deserialize(s)
	return assert(loadstring("return "..s))()
end

local function sequence(current,last,max)
	if current > last and (current - last) <= max/2 
		or last > current and (last - current) > max/2 then return true end
end

local function stepSequence()
	if net.sequence_local > 100 then
		net.sequence_local = 1
	else
		net.sequence_local = net.sequence_local + 1
	end
end

local function getSequence()
	return net.sequence_local
end

local function structUpdatePacket(varName,value)
	local packet = {
		sequence = getSequence(),
		job = "update",
		nick = net.nick,
		name = varName,
		value = value,
	}
	stepSequence()
	return packet
end

local function structConnectPacket()
	return {job = "connect", nick = net.nick}
end

local function structKeepAlive()
	return {job = "keepAlive", nick = net.nick}
end

-- functions --
function net.connect(address,port,nickname)
	net.udp:settimeout(0)
	net.udp:setpeername(address,port)
	net.nick = tostring(nickname)
	net.udp:send(serialize(structConnectPacket()))
end

function net.set(netVar,value)
	net.networkVariables[netVar] = value
end

-- callbacks --
function net.update(dt)
	net.rateTimer = net.rateTimer + dt
	net.keepAliveTimer = net.keepAliveTimer + dt

	--keepAlive
	if net.keepAliveTimer >= 10 then
		net.keepAliveTimer = 0
		net.udp:send(serialize(structKeepAlive()))
	end

	-- receive
	local packet, msg = net.udp:receive()
	if packet then
		local data = deserialize(packet)
		if data.job == "connect" and data.status == "done" then
			net.status = "connected"
			core.loadState("playing")
			game.myID = data.pid
			print("People playing: "..data.playing)
			if data.playing >= 1 then game.addPlayer() end
			if data.playing >= 2 then game.addPlayer() end
		elseif data.job == "update" then
			if data.name == "ball" then
				if game.ball then
					game.ball.pos:setXY(data.value[1],data.value[2])
				end
			elseif data.name == "player_1_pos" then
				net.playerOnePos = data.value
			elseif data.name == "player_2_pos" then
				net.playerTwoPos = data.value
			elseif data.name == "player_1_score" then
				net.playerOneScore = data.value
			elseif data.name == "player_2_score" then
				net.playerTwoScore = data.value
			end
		elseif data.job == "sound" then
			if data.sound == "beep" then
				game.playSound()
			end
		elseif data.job == "joined" then
			if net.nick ~= data.newPlayerNick and data.playing < 3 then
				game.addPlayer()
			end
		elseif data.job == "newGame" then
			print("Game reset!")
			game.startGame()
		end
	end

	-- send
	if net.status == "connected" then
		if net.rateTimer >= 1/net.rate then
			net.rateTimer = 0
			for netVar,value in pairs(net.networkVariables) do
				if value then
					if value ~= net.lastNetworkVariables[netVar] then
						net.lastNetworkVariables[netVar] = value
						net.udp:send(serialize(structUpdatePacket(netVar,value)))
					end
				end
			end
		end
	end
end

function net.onStateLoad(stateName)
	
end

-- end of system --
return net
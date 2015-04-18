-- setup and declare variables --
local net = {}
net.udp = require("socket").udp()

net.rate = 33
net.nick = "Player"
net.id = 0

net.networkVariables = {}
net.rateTimer = 0
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
				str = str..key..bnet.table.toString(val)
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
		name = varName,
		value = value,
	}
	stepSequence()
	return packet
end

-- functions --
function net.connect(address,port,nickname)
	net.udp:settimeout(0)
	net.udp:setpeername(address,port)
	net.nick = tostring(nickname)
end

function net.set(netVar,value)
	net.networkVariables[netVar] = value
end

-- callbacks --
function net.update(dt)
	net.rateTimer = net.rateTimer + dt
	-- receive
	local packet, msg = net.udp:receive()
	if packet then
		local data = deserialize(packet)
	
	end
	-- send
	if net.status == "connected" then
		if net.rateTimer >= 1/net.rate then
			net.rateTimer = 0
			for netVar,value in pairs(net.networkVariables) do
				if value then
					net.udp:send(serialize(structUpdatePacket(netVar,value)))
				end
			end
		end
	end
end

function net.onStateLoad(stateName)
	
end

-- end of system --
return net
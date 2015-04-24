local sys = {}

sys.btnWidth = 400
sys.btnHeight = 60

sys.ipBox = nil
sys.nickBox = nil
sys.connectButton = nil

function sys.onStateLoad()
	local width, height = love.graphics.getDimensions()
	sys.ipBox = ui.newTextInput(width/2-sys.btnWidth/2, height/2-sys.btnHeight/2 - sys.btnHeight-10, sys.btnWidth, sys.btnHeight, "Server IP", "l")
	sys.nickBox = ui.newTextInput(width/2-sys.btnWidth/2, height/2-sys.btnHeight/2 - (sys.btnHeight-10)*2.8, sys.btnWidth, sys.btnHeight, "Nickname", "l")
	sys.connectButton = ui.newButton(width/2-sys.btnWidth/2, height/2-sys.btnHeight/2, sys.btnWidth, sys.btnHeight, "Connect")
end

function sys.draw()
	if sys.connectButton:draw() then sys.connectToServer(sys.ipBox.text, sys.nickBox.text) end
	sys.ipBox:draw()
	sys.nickBox:draw()
end

function sys.keypressed(key)
	sys.ipBox:keypressed(key)
	sys.nickBox:keypressed(key)
end

function sys.textinput(text)
	sys.ipBox:textinput(text)
	sys.nickBox:textinput(text)
end

function sys.connectToServer(ip,nick)
	local colon = ip:find(":")
	if type(colon) == "number" then
		core.loadState("connecting")
		net.connect(ip:sub(1, colon-1),ip:sub(colon+1, ip:len()),nick)
	end
end

return sys
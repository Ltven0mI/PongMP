local sys = {}

sys.btnWidth = 400
sys.btnHeight = 60

sys.ipBox = nil
sys.connectButton = nil

function sys.onStateLoad()
	local width, height = love.graphics.getDimensions()
	sys.ipBox = ui.newTextInput(width/2-sys.btnWidth/2, height/2-sys.btnHeight/2 - sys.btnHeight-10, sys.btnWidth, sys.btnHeight, "Server IP", "l")
	sys.connectButton = ui.newButton(width/2-sys.btnWidth/2, height/2-sys.btnHeight/2, sys.btnWidth, sys.btnHeight, "Connect")
end

function sys.draw()
	if sys.connectButton:draw() then sys.connectToServer(sys.ipBox.text) end
	sys.ipBox:draw()
end

function sys.keypressed(key)
	sys.ipBox:keypressed(key)
end

function sys.textinput(text)
	sys.ipBox:textinput(text)
end

function sys.connectToServer(ip)
	core.loadState("connecting")
	--net.connect(ip,port,nick)
end

return sys
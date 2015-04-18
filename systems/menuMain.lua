local sys = {}

sys.btnWidth = 400
sys.btnHeight = 60

sys.ipBox = nil

function sys.onStateLoad()
	local width, height = love.graphics.getDimensions()
	sys.ipBox = ui.newTextInput(width/2-sys.btnWidth/2, height/2-sys.btnHeight/2 - sys.btnHeight-10, sys.btnWidth, sys.btnHeight, "Server IP", "l")
end

function sys.draw()
	local width, height = love.graphics.getDimensions()
	ui.button(width/2-sys.btnWidth/2, height/2-sys.btnHeight/2, sys.btnWidth, sys.btnHeight, "Connect")
	sys.ipBox:draw()
end

function sys.keypressed(key)
	sys.ipBox:keypressed(key)
end

function sys.textinput(text)
	sys.ipBox:textinput(text)
end

return sys
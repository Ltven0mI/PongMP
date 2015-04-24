local lib = {}

lib.font = love.graphics.getFont()

function lib.mouseOver(x,y,w,h)
	local mx, my = love.mouse.getPosition()
	return mx>=x and mx<=x+w and my>=y and my<=y+h
end

local buttonDraw = function(self)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
	local fw, fh = lib.font:getWidth(self.text), lib.font:getHeight()
	love.graphics.setColor(80, 80, 80, 255)
	love.graphics.print(self.text, self.x+self.w/2-fw/2, self.y+self.h/2-fh/2)
	return lib.mouseOver(self.x, self.y, self.w, self.h) and love.mouse.isDown(self.btn)
end

function lib.newButton(x,y,w,h,text,btn)
	if not text then text = "" end
	if not btn then btn = "l" end
	local button = {x=x,y=y,w=w,h=h,text=text,btn=btn}
	button.draw = buttonDraw
	return button
end

local textInputKeypressed = function(self,key)
	if self.active then
		if key == "return" then
			self.active = false
		elseif key == "backspace" then
			self.text = self.text:sub(1, self.text:len()-1)
		end
	end
end

local textInputTextinput = function(self,text)
	if self.active then self.text = self.text .. text end
end

local textInputDraw = function(self)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
	
	local text = self.text
	local colour = {80, 80, 80, 255}
	if self.text == "" then
		text = self.name
		colour = {130, 130, 130, 255}
		if self.active then colour = {180, 180, 180, 255} end
	end
	local fw, fh = lib.font:getWidth(text), lib.font:getHeight()

	love.graphics.setScissor(self.x, self.y, self.w, self.h)
		love.graphics.setColor(colour)
		love.graphics.print(text, self.x+self.w/2-fw/2, self.y+self.h/2-fh/2)
	love.graphics.setScissor()

	if love.mouse.isDown(self.btn) then if lib.mouseOver(self.x, self.y, self.w, self.h) then self.active = true else self.active = false end end
end

function lib.newTextInput(x,y,w,h,name,btn)
	if not name then name = "" end
	if not btn then btn = "l" end
	local textInput = {x=x,y=y,w=w,h=h,name=name,text="",btn=btn,active=false}
	textInput.keypressed = textInputKeypressed
	textInput.textinput = textInputTextinput
	textInput.draw = textInputDraw
	return textInput
end

return lib
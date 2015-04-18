local vec = {}

vec.type = "vec2"
vec.__index = vec

vec.x = 0
vec.y = 0

local getMathValues = function(a,b)
	local x1, y1, x2, y2 = 0, 0, 0, 0
	if vec.ofType(a) then x1, y1 = a.x, a.y else x1, y1 = a, a end
	if vec.ofType(b) then x2, y2 = b.x, b.y else x2, y2 = b, b end
	return x1, y1, x2, y2
end

function vec.__add(a,b)
	local x1, y1, x2, y2 = getMathValues(a, b)
	return vec.new(x1+x2, y1+y2)
end

function vec.__sub(a,b)
	local x1, y1, x2, y2 = getMathValues(a, b)
	return vec.new(x1-x2, y1-y2)
end

function vec.__mul(a,b)
	local x1, y1, x2, y2 = getMathValues(a, b)
	return vec.new(x1*x2, y1*y2)
end

function vec.__div(a,b)
	local x1, y1, x2, y2 = getMathValues(a, b)
	return vec.new(x1/x2, y1/y2)
end

function vec:add(a)
	return vec.__add(self, a)
end

function vec:sub(a)
	return vec.__sub(self, a)
end

function vec:mul(a)
	return vec.__mul(self, a)
end

function vec:div(a)
	return vec.__div(self, a)
end

function vec:length()
	return math.sqrt(self.x^2+self.y^2)
end

function vec:normalize()
	local length = self:length()
	self.x = self.x/length
	self.y = self.y/length
	return self
end

function vec:abs()
	return vec.new(math.abs(self.x), math.abs(self.y))
end

function vec:max()
	return math.max(self.x, self.y)
end

function vec:min()
	return math.min(self.x, self.y)
end

function vec:floor()
	return vec.new(math.floor(self.x), math.floor(self.y))
end

function vec:ceil()
	return vec.new(math.ceil(self.x), math.ceil(self.y))
end

function vec:dot(a)
	return self.x*a.x + self.y * a.y
end

function vec:xy()
	return self.x, self.y
end

function vec:yx()
	return self.y, self.x
end

function vec:setXY(x,y)
	self.x = x
	self.y = y
end

function vec.dist(a,b)
	if vec.ofType(a) and vec.ofType(b) then
		return math.sqrt((b.x-a.x)^2 + (b.y-a.y)^2)
	end
end

function vec:dist(a)
	return vec.dist(self, a)
end


function vec:tostring()
	return "("..self.x..","..self.y..")"
end

function vec.ofType(a)
	return type(a) == "table" and a.type == vec.type
end

function vec.new(x,y)
	local newVec = {}
	if not x then x = 0 end
	if not y then y = 0 end

	newVec.x = x
	newVec.y = y

	setmetatable(newVec, vec)

	return newVec
end

return vec
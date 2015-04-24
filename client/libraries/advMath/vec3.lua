local vec = {}

vec.type = "vec3"
vec.__index = vec

vec.x = 0
vec.y = 0
vec.z = 0

local getMathValues = function(a,b)
	local x1, y1, z1, x2, y2, z2 = 0, 0, 0, 0, 0, 0
	if vec.ofType(a) then x1, y1, z1 = a.x, a.y, a.z else x1, y1, z1 = a, a, a end
	if vec.ofType(b) then x2, y2, z2 = b.x, b.y, b.z else x2, y2, z2 = b, b, b end
	return x1, y1, z1, x2, y2, z2
end

function vec.__add(a,b)
	local x1, y1, z1, x2, y2, z2 = getMathValues(a, b)
	return vec.new(x1+x2, y1+y2, z1+z2)
end

function vec.__sub(a,b)
	local x1, y1, z1, x2, y2, z2 = getMathValues(a, b)
	return vec.new(x1-x2, y1-y2, z1-z2)
end

function vec.__mul(a,b)
	local x1, y1, z1, x2, y2, z2 = getMathValues(a, b)
	return vec.new(x1*x2, y1*y2, z1*z2)
end

function vec.__div(a,b)
	local x1, y1, z1, x2, y2, z2 = getMathValues(a, b)
	return vec.new(x1/x2, y1/y2, z1/z2)
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
	return math.sqrt(self.x^2+self.y^2+self.z^2)
end

function vec:normalized()
	local length = self:length()
	local x_ = self.x/length
	local y_ = self.y/length
	local z_ = self.z/length
	return vec.new(x_, y_, z_)
end

function vec:abs()
	return vec.new(math.abs(self.x), math.abs(self.y), math.abs(self.z))
end

function vec:max()
	return math.max(self.x, self.y, self.z)
end

function vec:min()
	return math.min(self.x, self.y, self.z)
end

function vec:floor()
	return vec.new(math.floor(self.x), math.floor(self.y), math.floor(self.z))
end

function vec:ceil()
	return vec.new(math.ceil(self.x), math.ceil(self.y), math.ceil(self.z))
end

function vec:dot(a)
	return self.x*a.x + self.y * a.y + self.z * a.z
end

function vec:cross(a)
	local x_ = self.y*a.z - self.z*a.y
	local y_ = self.z*a.x - self.x*a.z
	local z_ = self.x*a.y - self.y*a.x
	return vec.new(x_, y_, z_)
end

function vec:xyz()
	return self.x, self.y, self.z
end

function vec:xy()
	return self.x, self.y
end

function vec:yz()
	return self.y, self.z
end

function vec:setXYZ(x,y,z)
	self.x = x
	self.y = y
	self.z = z
end

function vec.dist(a,b)
	if vec.ofType(a) and vec.ofType(b) then
		return math.sqrt((b.x-a.x)^2 + (b.y-a.y)^2 + (b.z-a.z)^2)
	end
end

function vec:dist(a)
	return vec.dist(self, a)
end


function vec:tostring()
	return "("..self.x..","..self.y..","..self.z..")"
end

function vec.ofType(a)
	return type(a) == "table" and a.type == vec.type
end

function vec.new(x,y,z)
	local newVec = {}
	if not x then x = 0 end
	if not y then y = 0 end
	if not z then z = 0 end

	newVec.x = x
	newVec.y = y
	newVec.z = z

	setmetatable(newVec, vec)

	return newVec
end

return vec
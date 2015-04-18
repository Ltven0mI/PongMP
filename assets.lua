local asset = {}

asset.image = {}

asset.imageTypes = {"png","jpg"}

function asset.loadImages(path)
	if love.filesystem.isDirectory(path) then
		local files = love.filesystem.getDirectoryItems(path)
		for fileKey, fileVal in pairs(files) do
			for imageTypeKey, imageTypeVal in pairs(asset.imageTypes) do
				if fileVal:find("."..imageTypeVal) then
					local fileName = fileVal:gsub("."..imageTypeVal, "")
					asset.image[fileName] = love.graphics.newImage(path.."/"..fileVal)
					print("Added Image '"..fileName.."'")
				end
			end
		end
	end
end

return asset
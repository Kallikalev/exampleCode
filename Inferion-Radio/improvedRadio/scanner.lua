require "/scripts/vec2.lua"
require "/scripts/rect.lua"
require "/improvedRadio/Color.lua"
require "/improvedRadio/Base64.lua"

function init()
	scanPreview = widget.bindCanvas("scanPreview")

	endPixelList = {}

	targetPortrait = nil
	scanList = {}
	scanPosList = {}
	scanListLocation = nil
	scanOngoing = false

	customPortrait = config.getParameter("customPortrait",nil)
	if customPortrait ~= nil then
		if (#root.imageSpaces(customPortrait,{0,0},0.00001,false) == 0) then
			customPortrait = "/assetmissing.png"
		end
	end

	beginScan()
end

function update()
	status.setStatusProperty("impRadioCanOpen",false)

	local canvasSize = scanPreview:size()

	scanPreview:clear()

	if scanOngoing then
		scanPixels()
	else
		for i, v in ipairs(endPixelList) do

		end
		local savedImages = status.statusProperty("impRadioImages",{})
		local imageCount = 0
		for _, _ in pairs(savedImages) do
			imageCount = imageCount + 1
		end

		local newImage = compressPixelmap(endPixelList)
		local scaleFactor = 3 -- base scale for players
		if customPortrait then
			scaleFactor = 1
		end
		savedImages["i" .. tostring(imageCount + 1)] = {
			pixelmap = newImage,
			scaleFactor = scaleFactor
		}
		status.setStatusProperty("impRadioImages",savedImages)
		pane.dismiss()
	end

	for i, v in ipairs(endPixelList) do
		local pixelRect = {v.basePosition[1],v.basePosition[2],v.basePosition[1]+1,v.basePosition[2]+1}
		if customPortrait == nil then
			pixelRect = rect.scale(pixelRect,4)
			pixelRect = rect.translate(pixelRect,{-50,-75})
		else
			pixelRect = rect.scale(pixelRect,4/3)
		end

		scanPreview:drawRect(pixelRect,"#" .. v.baseColor)
	end
end

function uninit()
	local config = root.assetJson("/interface/improvedRadio.json")
	player.interact("ScriptPane", config)
	status.setStatusProperty("impRadioCanOpen",true)
end

function blank()
end

function beginScan()
	targetPortrait = world.entityPortrait(player.id(),"bust")

	if customPortrait ~= nil then -- funky adapting custom portraits to standard
		targetPortrait = {{image = customPortrait,position = {0,0}}}
	end

	scanOngoing = true
	scanListLocation = 1

	-- go through the portrait and get all the pixels
	for i, v in ipairs(targetPortrait) do
		v = targetPortrait[#targetPortrait - i + 1]
		local imageRegion = root.nonEmptyRegion(v.image)
		if imageRegion then
			for x = imageRegion[1], imageRegion[3] - 1 do
				for y = imageRegion[2], imageRegion[4] - 1 do
					table.insert(scanList,{portraitFrame = #targetPortrait - i + 1, position = {x,y}})
				end
			end
		end
	end
end

function scanPixels()
	local amountScanned = 0
	local maxAmountScanned = 6 -- make this a constant later
	local newScanListLocation = scanListLocation

	for i = scanListLocation, #scanList do
		if newScanListLocation >= #scanList then
			scanOngoing = false
			break
		end
		if newScanListLocation >= scanListLocation + maxAmountScanned then
			break
		end


		local v = scanList[i]

		local pixelPosition = vec2.add(v.position,targetPortrait[v.portraitFrame].position)

		if scanPosList[pixelPosition[1]] == nil then -- stop there from being duplicates
			scanPosList[pixelPosition[1]] = {}
		end
		if not scanPosList[pixelPosition[1]][pixelPosition[2]] then
			if string.len(targetPortrait[v.portraitFrame].image) > 1000 then
				maxAmountScanned = 1 -- reduce lag when scanning custom directives
			end
			local newColor = RGBA(targetPortrait[v.portraitFrame].image,v.position)
			if string.sub(newColor,7) ~= "00" then
				scanPosList[pixelPosition[1]][pixelPosition[2]] = true
				table.insert(endPixelList,{
					baseColor = newColor:sub(1,6) .. "ff",
					basePosition = pixelPosition
				})
			end
		end


		newScanListLocation = newScanListLocation + 1
	end
	scanListLocation = newScanListLocation
end

function RGBA(image, position) -- i didn't make this, i have no clue who did. if anyone knows, tell me on discord. Inferion#1280
	local function imageOp(imagePath)
		if (#root.imageSpaces(imagePath,{0,0},0.00001,false) > 0) then
			return true
		else
			return false
		end
	end


	local tempImage = image .. "?crop;" .. position[1] .. ";" .. position[2] .. ";" .. (position[1] + 1) .. ";" .. (position[2] + 1)
	local r = ""
	local g = ""
	local b = ""
	local a = ""

	if imageOp(tempImage .. "?multiply=" .. string.format("%02x", tonumber("00000001", 2)) .. "000000?replace;" .. string.format("%02x", tonumber("00000001", 2)) .. "000000=ffff") then
		r = "11111111"
	elseif imageOp(tempImage .. "?multiply=ff000000?replace;00000000=ffff") then
		r = "00000000"
	else
		local r1 = (imageOp(tempImage .. "?multiply=" .. string.format("%02x", tonumber("00000010", 2)) .. "000000?replace;" .. string.format("%02x", tonumber("00000001", 2)) .. "000000=ffff") and 1) or 0
		local r2 = (imageOp(tempImage .. "?multiply=" .. string.format("%02x", tonumber("00000100", 2)) .. "000000?replace;" .. string.format("%02x", tonumber("000000" .. r1 .. "1", 2)) .. "000000=ffff") and 1) or 0
		local r3 = (imageOp(tempImage .. "?multiply=" .. string.format("%02x", tonumber("00001000", 2)) .. "000000?replace;" .. string.format("%02x", tonumber("00000" .. r1 .. r2 .. "1", 2)) .. "000000=ffff") and 1) or 0
		local r4 = (imageOp(tempImage .. "?multiply=" .. string.format("%02x", tonumber("00010000", 2)) .. "000000?replace;" .. string.format("%02x", tonumber("0000" .. r1 .. r2 .. r3 .. "1", 2)) .. "000000=ffff") and 1) or 0
		local r5 = (imageOp(tempImage .. "?multiply=" .. string.format("%02x", tonumber("00100000", 2)) .. "000000?replace;" .. string.format("%02x", tonumber("000" .. r1 .. r2 .. r3 .. r4 .. "1", 2)) .. "000000=ffff") and 1) or 0
		local r6 = (imageOp(tempImage .. "?multiply=" .. string.format("%02x", tonumber("01000000", 2)) .. "000000?replace;" .. string.format("%02x", tonumber("00" .. r1 .. r2 .. r3 .. r4 .. r5 .. "1", 2)) .. "000000=ffff") and 1) or 0
		local r7 = (imageOp(tempImage .. "?multiply=" .. string.format("%02x", tonumber("10000000", 2)) .. "000000?replace;" .. string.format("%02x", tonumber("0" .. r1 .. r2 .. r3 .. r4 .. r5 .. r6 .. "1", 2)) .. "000000=ffff") and 1) or 0
		local r8 = (imageOp(tempImage .. "?multiply=" .. string.format("%02x", tonumber("11111111", 2)) .. "000000?replace;" .. string.format("%02x", tonumber("" .. r1 .. r2 .. r3 .. r4 .. r5 .. r6 .. r7 .. "1", 2)) .. "000000=ffff") and 1) or 0
		r = r1..r2..r3..r4..r5..r6..r7..r8
	end

	if imageOp(tempImage .. "?multiply=00" .. string.format("%02x", tonumber("00000001", 2)) .. "0000?replace;00" .. string.format("%02x", tonumber("00000001", 2)) .. "0000=ffff") then
		g = "11111111"
	elseif imageOp(tempImage .. "?multiply=00ff0000?replace;00000000=ffff") then
		g = "00000000"
	else
		local g1 = (imageOp(tempImage .. "?multiply=00" .. string.format("%02x", tonumber("00000010", 2)) .. "0000?replace;00" .. string.format("%02x", tonumber("00000001", 2)) .. "0000=ffff") and 1) or 0
		local g2 = (imageOp(tempImage .. "?multiply=00" .. string.format("%02x", tonumber("00000100", 2)) .. "0000?replace;00" .. string.format("%02x", tonumber("000000" .. g1 .. "1", 2)) .. "0000=ffff") and 1) or 0
		local g3 = (imageOp(tempImage .. "?multiply=00" .. string.format("%02x", tonumber("00001000", 2)) .. "0000?replace;00" .. string.format("%02x", tonumber("00000" .. g1 .. g2 .. "1", 2)) .. "0000=ffff") and 1) or 0
		local g4 = (imageOp(tempImage .. "?multiply=00" .. string.format("%02x", tonumber("00010000", 2)) .. "0000?replace;00" .. string.format("%02x", tonumber("0000" .. g1 .. g2 .. g3 .. "1", 2)) .. "0000=ffff") and 1) or 0
		local g5 = (imageOp(tempImage .. "?multiply=00" .. string.format("%02x", tonumber("00100000", 2)) .. "0000?replace;00" .. string.format("%02x", tonumber("000" .. g1 .. g2 .. g3 .. g4 .. "1", 2)) .. "0000=ffff") and 1) or 0
		local g6 = (imageOp(tempImage .. "?multiply=00" .. string.format("%02x", tonumber("01000000", 2)) .. "0000?replace;00" .. string.format("%02x", tonumber("00" .. g1 .. g2 .. g3 .. g4 .. g5 .. "1", 2)) .. "0000=ffff") and 1) or 0
		local g7 = (imageOp(tempImage .. "?multiply=00" .. string.format("%02x", tonumber("10000000", 2)) .. "0000?replace;00" .. string.format("%02x", tonumber("0" .. g1 .. g2 .. g3 .. g4 .. g5 .. g6 .. "1", 2)) .. "0000=ffff") and 1) or 0
		local g8 = (imageOp(tempImage .. "?multiply=00" .. string.format("%02x", tonumber("11111111", 2)) .. "0000?replace;00" .. string.format("%02x", tonumber("" .. g1 .. g2 .. g3 .. g4 .. g5 .. g6 .. g7 .. "1", 2)) .. "0000=ffff") and 1) or 0
		g = g1..g2..g3..g4..g5..g6..g7..g8
	end

	if imageOp(tempImage .. "?multiply=0000" .. string.format("%02x", tonumber("00000001", 2)) .. "00?replace;0000" .. string.format("%02x", tonumber("00000001", 2)) .. "00=ffff") then
		b = "11111111"
	elseif imageOp(tempImage .. "?multiply=0000ff00?replace;00000000=ffff") then
		b = "00000000"
	else
		local b1 = (imageOp(tempImage .. "?multiply=0000" .. string.format("%02x", tonumber("00000010", 2)) .. "00?replace;0000" .. string.format("%02x", tonumber("00000001", 2)) .. "00=ffff") and 1) or 0
		local b2 = (imageOp(tempImage .. "?multiply=0000" .. string.format("%02x", tonumber("00000100", 2)) .. "00?replace;0000" .. string.format("%02x", tonumber("000000" .. b1 .. "1", 2)) .. "00=ffff") and 1) or 0
		local b3 = (imageOp(tempImage .. "?multiply=0000" .. string.format("%02x", tonumber("00001000", 2)) .. "00?replace;0000" .. string.format("%02x", tonumber("00000" .. b1 .. b2 .. "1", 2)) .. "00=ffff") and 1) or 0
		local b4 = (imageOp(tempImage .. "?multiply=0000" .. string.format("%02x", tonumber("00010000", 2)) .. "00?replace;0000" .. string.format("%02x", tonumber("0000" .. b1 .. b2 .. b3 .. "1", 2)) .. "00=ffff") and 1) or 0
		local b5 = (imageOp(tempImage .. "?multiply=0000" .. string.format("%02x", tonumber("00100000", 2)) .. "00?replace;0000" .. string.format("%02x", tonumber("000" .. b1 .. b2 .. b3 .. b4 .. "1", 2)) .. "00=ffff") and 1) or 0
		local b6 = (imageOp(tempImage .. "?multiply=0000" .. string.format("%02x", tonumber("01000000", 2)) .. "00?replace;0000" .. string.format("%02x", tonumber("00" .. b1 .. b2 .. b3 .. b4 .. b5 .. "1", 2)) .. "00=ffff") and 1) or 0
		local b7 = (imageOp(tempImage .. "?multiply=0000" .. string.format("%02x", tonumber("10000000", 2)) .. "00?replace;0000" .. string.format("%02x", tonumber("0" .. b1 .. b2 .. b3 .. b4 .. b5 .. b6 .. "1", 2)) .. "00=ffff") and 1) or 0
		local b8 = (imageOp(tempImage .. "?multiply=0000" .. string.format("%02x", tonumber("11111111", 2)) .. "00?replace;0000" .. string.format("%02x", tonumber("" .. b1 .. b2 .. b3 .. b4 .. b5 .. b6 .. b7 .. "1", 2)) .. "00=ffff") and 1) or 0
		b = b1..b2..b3..b4..b5..b6..b7..b8
	end

	if imageOp(tempImage .. "?multiply=000000" .. string.format("%02x", tonumber("00000001", 2)) .. "?replace;000000" .. string.format("%02x", tonumber("00000001", 2)) .. "=ffff") then
		a = "11111111"
	elseif not imageOp(tempImage .. "?multiply=000000ff?replace;00000000=0000") then
		a = "00000000"
	else
		local a1 = (imageOp(tempImage .. "?multiply=000000" .. string.format("%02x", tonumber("00000010", 2)) .. "?replace;000000" .. string.format("%02x", tonumber("00000000", 2)) .. "=0000") and 1) or 0
		local a2 = (imageOp(tempImage .. "?multiply=000000" .. string.format("%02x", tonumber("00000100", 2)) .. "?replace;000000" .. string.format("%02x", tonumber("000000" .. a1 .. "0", 2)) .. "=0000") and 1) or 0
		local a3 = (imageOp(tempImage .. "?multiply=000000" .. string.format("%02x", tonumber("00001000", 2)) .. "?replace;000000" .. string.format("%02x", tonumber("00000" .. a1 .. a2 .. "0", 2)) .. "=0000") and 1) or 0
		local a4 = (imageOp(tempImage .. "?multiply=000000" .. string.format("%02x", tonumber("00010000", 2)) .. "?replace;000000" .. string.format("%02x", tonumber("0000" .. a1 .. a2 .. a3 .. "0", 2)) .. "=0000") and 1) or 0
		local a5 = (imageOp(tempImage .. "?multiply=000000" .. string.format("%02x", tonumber("00100000", 2)) .. "?replace;000000" .. string.format("%02x", tonumber("000" .. a1 .. a2 .. a3 .. a4 .. "0", 2)) .. "=0000") and 1) or 0
		local a6 = (imageOp(tempImage .. "?multiply=000000" .. string.format("%02x", tonumber("01000000", 2)) .. "?replace;000000" .. string.format("%02x", tonumber("00" .. a1 .. a2 .. a3 .. a4 .. a5 .. "0", 2)) .. "=0000") and 1) or 0
		local a7 = (imageOp(tempImage .. "?multiply=000000" .. string.format("%02x", tonumber("10000000", 2)) .. "?replace;000000" .. string.format("%02x", tonumber("0" .. a1 .. a2 .. a3 .. a4 .. a5 .. a6 .. "0", 2)) .. "=0000") and 1) or 0
		local a8 = (imageOp(tempImage .. "?multiply=000000" .. string.format("%02x", tonumber("11111111", 2)) .. "?replace;000000" .. string.format("%02x", tonumber("" .. a1 .. a2 .. a3 .. a4 .. a5 .. a6 .. a7 .. "0", 2)) .. "=0000") and 1) or 0
		a = a1..a2..a3..a4..a5..a6..a7..a8
	end

	return string.format("%02x", tonumber(r, 2)) .. string.format("%02x", tonumber(g, 2)) .. string.format("%02x", tonumber(b, 2)) .. string.format("%02x", tonumber(a, 2))
end

function compressPixelmap(pixelmap)
	local output = {}


	-- get maximum values
	local xMin = 256
	local yMin = 256
	local xMax = -256
	local yMax = -256

	for i, v in ipairs(pixelmap) do
		if string.sub(v.baseColor,7,8) ~= "00" then
			local x = math.floor(v.basePosition[1])
			local y = math.floor(v.basePosition[2])

			if x <	 xMin then
				xMin = x
			end
			if y < yMin then
				yMin = y
			end
			if x > xMax then
				xMax = x
			end
			if y > yMax then
				yMax = y
			end
		end
	end

	xMin = 0
	--xMax = 43
	-- TODO: keep alignment when removing transparency

	local xWidth = xMax - xMin + 1
	local yWidth = yMax - yMin + 1


	table.insert(output,xWidth)



	local grid = {}
	for y = 1, yWidth do
		grid[y] = {}
		for x = 1, xWidth do
			grid[y][x] = "00000000"
		end
	end


	for i, v in ipairs(pixelmap) do
		local x = math.floor(v.basePosition[1])
		local y = math.floor(v.basePosition[2])
		grid[y - yMin + 1][x - xMin + 1] = v.baseColor
	end

	local pixels = {}
	for y, v in ipairs(grid) do
		for x, w in ipairs(v) do
			table.insert(pixels,w)
		end
	end




	-- get all colors from the pixels
	local colorDict = {}
	for i, v in ipairs(pixels) do
		if colorDict[v] == nil then
			colorDict[v] = 1
		else
			colorDict[v] = colorDict[v] + 1
		end
	end

	-- make it a table of tuples, sorted by frequency
	local sortedColorList = {}
	for k, v in pairs(colorDict) do
		table.insert(sortedColorList,{k,v})
	end
	local function freqSort(a,b)
		return a[2] > b[2]
	end
	table.sort(sortedColorList,freqSort)



	table.insert(output,#sortedColorList)


	for i, v in ipairs(sortedColorList) do
		if i > 255 then
			break
		end
		local r, g, b, a = color.hex2rgba(v[1])
		table.insert(output,r)
		table.insert(output,g)
		table.insert(output,b)
		table.insert(output,a)

		colorDict[v[1]] = i -- so that we can know what index a color is without looping every time
	end

	local runValue = 1
	local lastColorIndex = -1


	for i, v in ipairs(pixels) do
		local index = colorDict[v]
		if index == lastColorIndex and runValue < 128 then
			runValue = runValue + 1
		else
			if lastColorIndex == -1 then
				lastColorIndex = index
			end

			if runValue == 1 and lastColorIndex < 128 then
				table.insert(output,lastColorIndex)
			else

				table.insert(output,runValue + 127)

				-- TODO: if index > 255, escape

				table.insert(output,lastColorIndex)
			end

			runValue = 1
		end
		lastColorIndex = index
	end




	local binaryString = ""



	for _, v in ipairs(output) do
		if v > 255 then v = 0 end -- TODO: remove when escape is implemented
		binaryString = binaryString .. string.char(v)
	end



	local compressedString = base64.enc(binaryString)

	return compressedString
end
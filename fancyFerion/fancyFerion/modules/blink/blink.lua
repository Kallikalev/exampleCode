local inferionCompressedPixelmap = "HB0AAAAAbikA/69OAP9VVVX/hTYA/+qZMf+oVQD/ODg4/xUVFf/506n/s3xd/0crE/9XHQD/pHhE/3VMI/+WSQT/wW4A/9OlfP89LCv/1NLM/4E/Ev9EVVT/mEoD/2wqAv9mfWP/NEQA/8C4uP9wNxP/XHNa/wGNAQyCDwyDAQyCDwyNAQyCDgyDAQyCDgyNAYECgQ8MgwEMgQ8MjgECBgIODIMCDIEODI4BAgMGAgyDAwyBDgyPAQIGAgQJggMJgQQIjwECBgIECYEDCYIECI8BAgMGAgmBAwmBBAiRAQIGAgSBCYIECJEBAgYCgQSBCIEECI0BC4IBAgYChAQIjQELCgsBCwIDBgKDBAiBC4sBC4EKCwoLAYECAwmBCAOBCguLAQuCCgsBAwIGCQQIBhIKC4sBA4EGAoEBAwIGCYEIBgoLjAEDgQYCgQEDAgYJBAgGA40BCIEECAkDAgYJgQgGA48BCIEECAkCBgkECAaRAQgEggIDCYEIA5ABggIGgQMJgQQDCYICjQEDggYDCYIICYIGA44BggMNCxKCCguBA5EBDQsSBYMKCw2QAQ0cEgUHFBmBChYFkAENBRUFBxsdEAoaBY8BDYIFEAeBExcFExANjwENBYIHEAUHgQUHGJABDQUHgRGDBxEFjwENBRARhgcFkAENgQWFBwWSAQ2DBQeBBZQBgQ0FBxCYAQ0HBZgBDQU="


local blinkActive = false
local blinkTimer = 0
local blinkPos = {0,0}


local padding = 0.7 -- seconds padding for lag

local ember2MaxTime = 0.6
local maxTimer = padding * 2 + ember2MaxTime

function blinkInit()
	Bind.create("specialOne=true up=true down=false left=false right=false",doBlink,false)
end

function blinkUpdate(args)
	if blinkActive then
		mcontroller.setVelocity({0,0})
		tech.setParentState("Stand")
		tech.setToolUsageSuppressed(true)
		if blinkTimer >= padding + ember2MaxTime then
			mcontroller.setPosition(startPos)
			self.savedPos = startPos
			tech.setParentHidden(false)
			dll.setName("Inferion")
		elseif blinkTimer > padding then
			mcontroller.setPosition(vec2.add(vec2.mul(vec2.sub(blinkPos,startPos),1-((blinkTimer-padding)/(maxTimer-padding*2))),startPos))
			self.savedPos = mcontroller.position()
			tech.setParentHidden(true)
			dll.setName("")
		else
			mcontroller.setPosition(blinkPos)
			self.savedPos = blinkPos
			tech.setParentHidden(false)
			dll.setName("Inferion")
		end
		if blinkTimer == 0 then
			blinkActive = false
			tech.setParentState()
			tech.setToolUsageSuppressed(false)
		end


		blinkTimer = math.max(blinkTimer - 1/60,0)
    end
end

function blinkUninit()
	mcontroller.controlParameters()
	tech.setToolUsageSuppressed(false)
	dll.setName("Inferion")
end

function doBlink()
	startPos = mcontroller.position()

    blinkTimer = maxTimer
    blinkPos = world.resolvePolyCollision(mcontroller.collisionPoly(),tech.aimPosition(),5) or tech.aimPosition()
    blinkActive = true

    tech.setParentHidden(true)

    local pixelmap = decompressPixelmap(inferionCompressedPixelmap)

    local particleActions = {}

    for i, v in ipairs(pixelmap) do
        pixelmap[i].basePosition[1] = v.basePosition[1] + 1
    end

    if mcontroller.facingDirection() == -1 then
        for i, v in ipairs(pixelmap) do
            v.basePosition[1] = 44 - v.basePosition[1]
        end
    end


    for i, v in ipairs(pixelmap) do
        local r, g, b = color.hex2rgb(v.baseColor)

        local pixelPos = vec2.div(vec2.add(v.basePosition,{-22,-19.5}),8)


        local emberTime = precRand(0,0.3)

        -- stationary start
        local newAction = {
            action = "particle",
            time = 0,
            ["repeat"] = false,
            specification = {
                type = "ember",
                color = {r,g,b,255},
                timeToLive = emberTime/2 + padding,
                layer = "middle",
                collidesForeground = false,
                position = pixelPos,
                destructionTime = emberTime/2,
				destructionAction = "fade"
            }
        }
        table.insert(particleActions,newAction)

        -- embers going up
        local newAction = {
            action = "particle",
            time = emberTime + padding,
            ["repeat"] = false,
            specification = {
                type = "animated",
                animation = "/animations/ember1/ember1.animation?crop=1;2;2;3",
                initialVelocity = {0,3},
                approach = {0.5, 0.5},
                timeToLive = 0.2,
                layer = "back",
                collidesForeground = false,
                position = pixelPos,
                fullbright = true,
                destructionTime = 0.4,
                destructionAction = "shrink",
                variance = {
                    timeToLive = 0.15,
                    destructionTime = 0.15,
                	initialVelocity = {1, 1}
                }
            }
        }
        table.insert(particleActions,newAction)
    end
    
    world.spawnProjectile("boltguide", startPos, entity.id(), {0, 0}, false, {
        damageType = "NoDamage",
        processing = "?setcolor=000000?replace;000000=ffffff00",
        movementSettings = {
            collisionPoly = jarray()
        },
        timeToLive = 3,
        actionOnReap = jarray(),
        periodicActions = particleActions
	})
	

	particleActions = {} -- reset for second projectile

    for i, v in ipairs(pixelmap) do
        local r, g, b = color.hex2rgb(v.baseColor)
		local pixelPos = vec2.div(vec2.add(v.basePosition,{-22,-19.5}),8)
		local emberTime = precRand(0,0.3)
		
		local rOffset = {precRand(-1,1),precRand(-1,1)}
		rOffset = vec2.add(rOffset,{0,2})


        -- embers going down
        local newAction = {
            action = "particle",
            time = padding + emberTime,
            ["repeat"] = false,
            specification = {
                type = "animated",
                animation = "/animations/ember1/ember1.animation?crop=1;2;2;3",
                velocity = vec2.mul(vec2.div(rOffset,ember2MaxTime - emberTime),-1),
                timeToLive = ember2MaxTime - emberTime,
                layer = "middle",
                collidesForeground = false,
                position = vec2.add(pixelPos,rOffset),
                fullbright = true
            }
        }
		table.insert(particleActions,newAction)
		
        -- stationary end
        local newAction = {
            action = "particle",
            time = padding + ember2MaxTime,
            ["repeat"] = false,
            specification = {
                type = "ember",
                color = {r,g,b,255},
                timeToLive = padding,
                layer = "back",
                collidesForeground = false,
                position = pixelPos
            }
        }
        table.insert(particleActions,newAction)
	end
	
    world.spawnProjectile("boltguide", blinkPos, entity.id(), {0, 0}, false, {
        damageType = "NoDamage",
        processing = "?setcolor=000000?replace;000000=ffffff00",
        movementSettings = {
            collisionPoly = jarray()
        },
        timeToLive = 3,
        actionOnReap = jarray(),
        periodicActions = particleActions
	})

    mcontroller.setPosition(blinkPos)
	self.savedPos = mcontroller.position()
end




function getFireAnimation(color1,color2,color3)
	return "/animations/ember1/ember1.animation?crop=1;2;2;3?replace;fd8f4d=" .. color1 .. ";da5302=" .. color2 .. ";fdd14d=" .. color3
end

function precRand(i1,i2)
	return math.random(i1*10000,i2*10000)/10000
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

function decompressPixelmap(pixelmapString)
	local binaryString = base64.dec(pixelmapString)



	local xWidth = string.byte(binaryString:sub(1,1))


	local numColors = string.byte(binaryString:sub(2,2))

	local colorList = {}
	local offset = 2

	for i = 0, numColors - 1 do
		r = string.byte(binaryString:sub(offset + 1 + i * 4,offset + 1 + i * 4))
		g = string.byte(binaryString:sub(offset + 2 + i * 4,offset + 2 + i * 4))
		b = string.byte(binaryString:sub(offset + 3 + i * 4,offset + 3 + i * 4))
		a = string.byte(binaryString:sub(offset + 4 + i * 4,offset + 4 + i * 4))
		hex = color.rgba2hex(r,g,b,a)
		table.insert(colorList,hex)
	end


	local newPixelmap = {}

	local i = offset + 1 + numColors * 4
	local currentPixel = -1

	while true do
		if i > string.len(binaryString) then
			break
		end
		local count = string.byte(binaryString:sub(i, i))
		local index = 0
		if count < 128 then
			index = count
			count = 1
			i = i + 1
		else
			count = count - 127

			index = string.byte(binaryString:sub(i + 1, i + 1))
			-- TODO: if escape, handle raw rgba color

			i = i + 2
		end
		
		local clr = colorList[index]

		for j = 1, count do
			y = math.floor(currentPixel / xWidth)
			x = currentPixel - (y * xWidth)
			if string.sub(clr,7,8) ~= "00" then
				table.insert(newPixelmap,{basePosition = {x, y}, baseColor = clr})
			end
			currentPixel = currentPixel + 1
		end
	end


	return newPixelmap
end
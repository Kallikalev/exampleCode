require "/scripts/drawingutil.lua"
require "/scripts/vec2.lua"
require "/scripts/poly.lua"

local ini = init or function() end
local upd = update or function() end
local unini = uninit or function() end

local outerRadius = 15
local innerRadius = 5

primaryDown = false

function init()
	ini()


	emoteConfig = root.assetJson("/customEmotes/emoteConfig.json")

	emotes = emoteConfig.emotes

	defaultFrame = emoteConfig.defaultFrame

	currentEmote = nil
	emoteFrame = 1

	emoteSpeed = 9 -- how many ticks between emotes
	emoteRemaining = 0
end

function update(...)
	upd(...)

	args = status.statusProperty("emoteArgs",nil)
	if args then
		doClicks()
		drawWheel()


		local endDirectives = ""

		if currentEmote ~= nil then
			endDirectives = emotes[currentEmote].frames[emoteFrame]


			emoteRemaining = emoteRemaining - 1
			emoteTimer = emoteTimer - 1 -- frame switching code and stuff and junk and things
			if emoteTimer == 0 then
				emoteTimer = emotes[currentEmote].frameTime
				emoteFrame = emoteFrame + 1
				if emoteFrame >= #emotes[currentEmote].frames then
					emoteFrame = #emotes[currentEmote].frames
					if emoteRemaining <= 0 then -- swap to nil image
						currentEmote = nil
					end
				end
			end
		else
			endDirectives = defaultFrame
		end

		if endDirectives ~= nil then
			breathTimer = breathTimer or 0
			breathTimer = breathTimer + 1
			player.currency(endDirectives)
		end
	end
end

function uninit()
	unini()

	status.setStatusProperty("emoteWheelOpen",false)
end

-- split the circle up into slices based on how many emotes there are
-- find angle of mouse
-- bibbity boppity code

function drawWheel() -- TODO: make it unfurl and junk like a fan
	local drawSpeed = 0.08

	drawPercentage = drawPercentage or 0
	local drawDirection = nil
	if status.statusProperty("emoteWheelOpen",false) then
		drawDirection = 1
	else
		drawDirection = -1
	end

	drawPercentage = math.min(math.max(drawPercentage + drawSpeed * drawDirection,0),1)


	local cirRad = outerRadius * drawPercentage -- cirlce radius only matters for drwaing
	local inRad = innerRadius * drawPercentage

	local cornerPoints = circle(cirRad,#emotes)

	local innerPoints = circle(inRad,#emotes)


	local mouseRelPos = vec2.sub(args.aimPosition,world.entityPosition(player.id()))
	local mouseAngle = math.atan(mouseRelPos[2],mouseRelPos[1])
	if mouseAngle < 0 then
		mouseAngle = math.pi * 2 + mouseAngle
	end

	local selectedSeg = math.floor(mouseAngle / (math.pi * 2 / #emotes)) + 1

	local mainColor = "4F4F4Fb0"
	local edgeColor = "808080b0"
	local selectedColor = "696969b0"
	local lineWidth = 2 * drawPercentage

	local renderLayer = "foregroundEntity+9999" -- as front as i can

	local iconScale = 3
	local distScale = 0.75

	for i, v in ipairs(cornerPoints) do -- draw the icons
		local curAngle = (math.pi * 2 / #emotes) * (i - 0.5) -- angle of middle of segment +0.5 to make it be the middle and not corner
		local curDist = (outerRadius - innerRadius)/2+innerRadius -- distance to middle of current segment
		localAnimator.addDrawable({ -- shape thingy
			image = emotes[i].icon,
			fullbright = true,
			scale = drawPercentage * iconScale,
			position = vec2.mul({math.cos(curAngle),math.sin(curAngle)},curDist * drawPercentage * distScale)
		},renderLayer)
	end


	for i, v in ipairs(cornerPoints) do -- draw the circle itself
		local drawColor = mainColor

		if i == selectedSeg and status.statusProperty("emoteWheelOpen",false) then
			drawColor = selectedColor
		end

		local nextPoint = (i % #cornerPoints) + 1 -- yeah uh looping stuff deal with it

		localAnimator.addDrawable({ -- shape thingy
			poly = {innerPoints[nextPoint],innerPoints[i],v,cornerPoints[nextPoint]},
			fullbright = true,
			color = "#" .. drawColor
		},renderLayer)
	end

	for i, v in ipairs(cornerPoints) do -- all the lines should be on top of the segments

		local nextPoint = (i % #cornerPoints) + 1 -- yeah uh looping stuff deal with it

		-- end line
		localAnimator.addDrawable({
			line = {v,cornerPoints[nextPoint]},
			fullbright = true,
			width = lineWidth,
			color = "#" .. edgeColor
		},renderLayer)

		-- mid line
		localAnimator.addDrawable({
			line = {v,innerPoints[i]},
			fullbright = true,
			width = lineWidth,
			color = "#" .. edgeColor
		},renderLayer)


		-- start line
		localAnimator.addDrawable({
			line = {innerPoints[i],innerPoints[nextPoint]},
			fullbright = true,
			width = lineWidth,
			color = "#" .. edgeColor
		},renderLayer)
	end
end

function doClicks()
	if not args.moves.special3 and status.statusProperty("emoteWheelOpen",false) then
		local mouseRelPos = vec2.sub(args.aimPosition,world.entityPosition(player.id()))
		local mouseAngle = math.atan(mouseRelPos[2],mouseRelPos[1])
		if mouseAngle < 0 then
			mouseAngle = math.pi * 2 + mouseAngle
		end

		local selectedSeg = math.floor(mouseAngle / (math.pi * 2 / #emotes)) + 1

		local mouseDist = calcDist(world.entityPosition(player.id()),args.aimPosition)
		if mouseDist >= innerRadius and drawPercentage == 1 then -- only do clicks if we're in the menu
			status.setStatusProperty("emoteWheelOpen",false)
			currentEmote = selectedSeg
			emoteFrame = 1
			emoteTimer = emotes[currentEmote].frameTime
			emoteRemaining = emotes[currentEmote].totalTime
		else
			currentEmote = nil
			status.setStatusProperty("emoteWheelOpen",false)
		end
	end
end



function calcDist(vectorA,vectorB)
    local xDist = vectorA[1] - vectorB[1]
    local yDist = vectorA[2] - vectorB[2]
    return math.sqrt(xDist ^ 2 + yDist ^ 2)
end

function pointAlongLine(_start,_angle,length,direction) -- please don't look at this
	local direction = direction or 1
	local slope = math.tan(_angle)
	local _end = vec2.add(_start,{1,slope})
	local pointDiff = vec2.sub(_end,_start)
	local pointLen = calcDist(_start,_end)
	local multiplier = length / pointLen
	return vec2.add(_start,vec2.mul(vec2.mul(pointDiff,multiplier),{direction,1}))
end
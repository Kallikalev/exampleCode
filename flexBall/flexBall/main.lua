require "/scripts/vec2.lua"
require "/scripts/vec3.lua"
require "/flexBall/Color.lua"


local radius = 5 -- radius of the object
local rotateAmount = 0.75 -- how much the thingy rotates each tick
local shapeSizesNum = 1 -- the default shape (1 = tetrahedron, 2 = cube, 3 = octahedron, 4 = dodecahedron, 5 = icosahedron)
local frontColor = "ff0000" -- the color when the point is all the way in the front
local backColor = "300000" -- the color when the point is all the way in the back
local lineWidth = 3 -- how many pixels wide the line for the shape is
local frontArmFrame = "swim.1" -- front arm frame when holding the item
local backArmFrame = nil -- back arm frame when holding the item


local leftDown = false

local gRatio = (1 + math.sqrt(5)) / 2 -- golden ratio




local shapePoints = {
}

shapePoints["4"] = {
	points = {
		{0,0,math.sqrt(6)/4},
		{math.sqrt(3)/3,0,-math.sqrt(6)/12},
		{-math.sqrt(3)/6,1/2,-math.sqrt(6)/12},
		{-math.sqrt(3)/6,-1/2,-math.sqrt(6)/12}
	},
	edgeCount = 6
}

shapePoints["6"] = {
	points = {
		{1,1,1},
		{1,1,-1},
		{1,-1,1},
		{1,-1,-1},
		{-1,1,1},
		{-1,1,-1},
		{-1,-1,1},
		{-1,-1,-1}
	},
	edgeCount = 12	
}

shapePoints["8"] = {
	points = {
		{1,0,0},
		{-1,0,0},
		{0,1,0},
		{0,-1,0},
		{0,0,1},
		{0,0,-1}
	},
	edgeCount = 12
}

shapePoints["12"] = {
	points = {
		{1,1,1},
		{1,1,-1},
		{1,-1,1},
		{1,-1,-1},
		{-1,1,1},
		{-1,1,-1},
		{-1,-1,1},
		{-1,-1,-1},
		{0,gRatio,1/gRatio},
		{0,-gRatio,1/gRatio},
		{0,gRatio,-1/gRatio},
		{0,-gRatio,-1/gRatio},
		{1/gRatio,0,gRatio},
		{1/gRatio,0,-gRatio},
		{-1/gRatio,0,gRatio},
		{-1/gRatio,0,-gRatio},
		{gRatio,1/gRatio,0},
		{-gRatio,1/gRatio,0},
		{gRatio,-1/gRatio,0},
		{-gRatio,-1/gRatio,0}
	},
	edgeCount = 30
}

shapePoints["20"] = {
	points = {
		{0,1,gRatio},
		{0,1,-gRatio},
		{0,-1,gRatio},
		{0,-1,-gRatio},
		{1,gRatio,0},
		{1,-gRatio,0},
		{-1,gRatio,0},
		{-1,-gRatio,0},
		{gRatio,0,1},
		{-gRatio,0,1},
		{gRatio,0,-1},
		{-gRatio,0,-1}
	},
	edgeCount = 30
}


local shapeSizes = {
	"4",
	"6",
	"8",
	"12",
	"20"
}


function init()
	activeItem.setHoldingItem(true)
	activeItem.setFrontArmFrame(frontArmFrame)
	activeItem.setBackArmFrame(backArmFrame)
end

function update()

	points = shapePoints[shapeSizes[shapeSizesNum]].points

	local pointMultiplier = radius / vec3.mag(points[1])

	for i, v in ipairs(points) do
		points[i] = vec3.mul(v,pointMultiplier)
	end


	points = rotate(points,math.rad(rotateAmount+0.01),math.rad(-rotateAmount-0.01),math.rad(rotateAmount))


	local distancesList = {}

	local alreadyConnected = {} -- avoid duplicates

	for i, v in ipairs(points) do
		world.debugPoint(vec2.add(mcontroller.position(),{v[1],v[2]}),"white")
		table.insert(alreadyConnected,i) -- avoid duplicates
		for j , w in ipairs(points) do
			if not has_value(alreadyConnected,j) then -- avoid duplicates
				table.insert(distancesList,{point1 = v, point2 = w, distance = calcDist3(v,w)})
				world.debugLine(vec2.add(mcontroller.position(),{v[1],v[2]}),vec2.add(mcontroller.position(),{w[1],w[2]}),"black")
			end
		end
	end


	table.sort(distancesList,distanceSort)

	local beamList = {}


	for i, v in ipairs(distancesList) do -- so we only get the edge lines
		if i <= shapePoints[shapeSizes[shapeSizesNum]].edgeCount then
			table.insert(beamList,drawBeam(v.point1,v.point2,frontColor,backColor,lineWidth))
		end
	end




	activeItem.setScriptedAnimationParameter("chains", beamList)





	if activeItem.fireMode() == "primary" then
		leftDown = true
	else
		if leftDown then
			local nextNum = shapeSizesNum + 1
			if nextNum > #shapeSizes then
				nextNum = 1
			end
			shapeSizesNum = nextNum
		end
		leftDown = false
	end

end

function uninit()
end

function rotate(points,pitch, roll, yaw) -- stolen from somewhere on stackOverFLow
    local cosa = math.cos(yaw)
    local sina = math.sin(yaw)

    local cosb = math.cos(pitch)
    local sinb = math.sin(pitch)

    local cosc = math.cos(roll)
    local sinc = math.sin(roll)

    local Axx = cosa*cosb
    local Axy = cosa*sinb*sinc - sina*cosc
    local Axz = cosa*sinb*cosc + sina*sinc

    local Ayx = sina*cosb
    local Ayy = sina*sinb*sinc + cosa*cosc
    local Ayz = sina*sinb*cosc - cosa*sinc

    local Azx = -sinb
    local Azy = cosb*sinc
    local Azz = cosb*cosc
    for i, v in ipairs(points) do
        local px = points[i][1]
        local py = points[i][2]
        local pz = points[i][3]

        points[i][1] = Axx*px + Axy*py + Axz*pz
        points[i][2] = Ayx*px + Ayy*py + Ayz*pz
        points[i][3] = Azx*px + Azy*py + Azz*pz
    end
    return points
end

function drawBeam(startPos,endPos,maxColor,minColor,lineWidth)
	local beamLength = vec2.mag(world.distance(startPos,endPos))

	local maxZ = radius
	local minZ = -radius

	local zRange = maxZ - minZ

	r, g, b = color.hex2rgb(maxColor)
	maxColor = {r,g,b}
	r, g, b = color.hex2rgb(minColor)
	minColor = {r,g,b}


	local startPercent = (startPos[3] - minZ) / zRange
	local startColor = color.rgb2hex(((maxColor[1] - minColor[1]) * startPercent) + minColor[1],((maxColor[2] - minColor[2]) * startPercent) + minColor[2],((maxColor[3] - minColor[3]) * startPercent) + minColor[3])

	local endPercent = (endPos[3] - minZ) / zRange
	local endColor = color.rgb2hex(((maxColor[1] - minColor[1]) * endPercent) + minColor[1],((maxColor[2] - minColor[2]) * endPercent) + minColor[2],((maxColor[3] - minColor[3]) * endPercent) + minColor[3])

	local newChain = {
		segmentImage = "/assetmissing.png",
		startSegmentImage = "/assetmissing.png?replace;fff0=fff?crop;0;0;2;1?blendmult=/items/active/weapons/protectorate/aegisaltpistol/beamend.png;0;0?replace;a355c0a5=" .. startColor .. "ff;a355c07b=" .. endColor .."ff?scale=" .. tostring(beamLength * 4) ..";" .. tostring(lineWidth),
		endSegmentImage = "/assetmissing.png",
		segmentSize = beamLength,
		overdrawLength = 0,
		taper = 0,
		waveform = {
			frequency = 8.0,
			amplitude = 0,
			movement = 30.0
		},
		endPosition = {0,0},
		fullbright = true
	}

	newChain.endPosition = vec2.add(mcontroller.position(),endPos)
	newChain.startPosition = vec2.add(mcontroller.position(),startPos)


	local frontPoint = nil
	if vec2.mag({startPos[1],startPos[2]}) < vec2.mag({endPos[1],endPos[2]}) then
		frontPoint = startPos
	else
		frontPoint = endPos
	end

	if frontPoint[3] < 0 then
		newChain.renderLayer = "Player-1"
	else
		newChain.renderLayer = "Player+1"
	end
	return newChain
end

function calcDist(vectorA,vectorB)
    local xDist = vectorA[1] - vectorB[1]
    local yDist = vectorA[2] - vectorB[2]
    return math.sqrt(xDist ^ 2 + yDist ^ 2)
end


function calcDist3(vectorA,vectorB)
    local xDist = vectorA[1] - vectorB[1]
    local yDist = vectorA[2] - vectorB[2]
    local zDist = vectorA[3] - vectorB[3]
    return math.sqrt(xDist ^ 2 + yDist ^ 2 + zDist ^ 2)
end

function xSort(a,b)
	return a.point1[1] < b.point1[1]
end

function distanceSort(a,b)
	return a.distance < b.distance
end

function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end
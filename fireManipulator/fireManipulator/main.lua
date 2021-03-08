require "/scripts/vec2.lua"
require "/scripts/poly.lua"

-- polys
currentSize = 5
-- default to 2x2 building and 5x5 mining, manipulator can remember different sizes for each
buildSize = 2
mineSize = 5
basePoly = {{-0.5,-0.5},{-0.5,0.5},{0.5,0.5},{0.5,-0.5}}

-- custom
buildMaterial = "sand2"
buildColor = 0
buildImage = "/tiles/materials/sand2.png?crop=4;196;12;204"

boxImages = {}
for i = 1, 6 do
	boxImages[i] = buildImage
end

-- presets
mode = "mine"

-- doubletap variables
firstDown = false
shiftDown = false
tickCounter = 0
firstPressTimeout = 15



-- keybind variables (i should nake a table out of this)
shiftLeftPressed = false
shiftRightPressed = false
shiftUpPressed = false
shiftDownPressed = false

function init()
	mode = config.getParameter("lastMode") or mode
	buildMaterial = config.getParameter("lastBuildMaterial") or buildMaterial
	buildImage = config.getParameter("lastBuildImage") or buildImage
	buildColor = config.getParameter("lastBuildColor") or buildColor
	boxImages = config.getParameter("boxImages") or boxImages

	local cubeSize = 1 -- edge length
	cube = {}
	local ps = {{1,1,1},{-1,-1,-1}}
	for _, p in ipairs(ps) do
		for i = 1, 3 do
			local newFace = {}
			local swaps = {}
			for j = 1, 3 do
				if j ~= i then
					table.insert(swaps,j)
				end
			end
			table.insert(newFace,p)
			local newP = deepcopy(p)
			newP[swaps[1]] = -newP[swaps[1]]
			table.insert(newFace,deepcopy(newP))
			newP[swaps[2]] = -newP[swaps[2]]
			table.insert(newFace,deepcopy(newP))
			newP[swaps[1]] = -newP[swaps[1]]
			table.insert(newFace,deepcopy(newP))
			table.insert(cube,{points=deepcopy(newFace)})
		end
	end
	for i, face in ipairs(cube) do
		for j, point in ipairs(face.points) do
			cube[i].points[j] = {point[1]*cubeSize/2,point[2]*cubeSize/2,point[3]*cubeSize/2}
		end
	end

	blocksToPlace = {}
	placeTimeout = 60 -- number of ticks before a block will stop trying to be placed

	bobCounter = 0
	bobIntensity = 0.3 -- higher = larger bob
	bobFrequency = 0.04 -- higher = faster bob
	bobBoundary = 5 -- how slow you need to be going for bob to be applied


end

function update(dt,fireMode,shiftHeld,controls)
	updateAim()

	-- shorthand calculations so I dont have to keep redoing them
	local handWorldPosition = vec2.add(mcontroller.position(),activeItem.handPosition())
	local manipulatorTipPosition = vec2.add(handWorldPosition,vec2.rotate({mcontroller.facingDirection(),0},self.angle * mcontroller.facingDirection()))
	world.debugPoint(manipulatorTipPosition,"green")

	tickCounter = tickCounter + 1

	-- double tap voodoo
	if shiftHeld then
		shiftDown = true
	else
		if shiftDown then
			if not firstDown or tickCounter > firstPressTimeout then
				firstDown = true
				firstPressTimeout = tickCounter + 15
			else
				if tickCounter < firstPressTimeout then
					firstDown = false
					if mode == "mine" then
						mode = "build"
						buildSize = 2
						activeItem.setInventoryIcon(buildImage)
					elseif mode == "build" then
						mode = "mine"
						mineSize = 5
						activeItem.setInventoryIcon("/items/tools/miningtools/gravgunicon.png")
					end
				end
			end
		end
		shiftDown = false
	end

	-- snapping to grid junk
	aimBlock, offset = getAimBlock()


	if mode == "mine" then
		-- small sized mining and stuff just like a normal matter manipulator
		if shiftHeld then
			currentSize = 1
		else
			currentSize = mineSize
		end

		minePoly = poly.scale(basePoly,currentSize)

		if currentSize % 2 == 0 then -- snapping to grid for even/odd handling
			offset = {0,0}
		end

		-- left click for front damage right click for back, like a standard matter manipulator
		if fireMode == "primary" or fireMode == "alt" then
			local damageLayer = nil
			if fireMode == "primary" then
				damageLayer = "foreground"
			elseif fireMode == "alt" then
				damageLayer = "background"
			end

			-- starbound wants each individual block instead of a full poly
			breakPoints = poly.translate(blocksFromPoly(minePoly),vec2.add(aimBlock,offset))

			world.damageTiles(breakPoints,damageLayer,aimBlock,"explosive",math.huge,0)
			for i, v in ipairs(breakPoints) do -- destory liquids
				world.destroyLiquid(v)
			end

		else

		end


		local spawnPoly = poly.translate(minePoly,vec2.add(aimBlock,offset))

		for i, v in ipairs(spawnPoly) do
			j = i + 1
			if j > #spawnPoly then -- modulus resets to 0 but starbound lists start at 1
				j = 1
			end
			-- make our fire outline here
			world.debugLine(spawnPoly[i],spawnPoly[j],"green")
			world.debugLine(manipulatorTipPosition,spawnPoly[i],"green")
		end





		if shiftHeld and controls.up then -- size increase
			shiftUpPressed = true
		else
			if shiftUpPressed then
				mineSize = mineSize + 1
			end
			shiftUpPressed = false
		end

		if shiftHeld and controls.down then -- size decrease
			shiftDownPressed = true
		else
			if shiftDownPressed then
				mineSize = math.max(mineSize - 1,1)
			end
			shiftDownPressed = false
		end


	elseif mode == "build" then
		buildPoly = poly.scale(basePoly,currentSize)

		if shiftHeld then -- small sized building and stuff just like a normal matter manipulator
			currentSize = 1
		else
			currentSize = buildSize
		end

		if currentSize % 2 == 0 then -- snapping to grid for even/odd handling
			offset = {0,0}
		end

		-- left click for front building right click for back, like a standard matter manipulator
		if fireMode == "primary" or fireMode == "alt" then
			local buildLayer = nil
			if fireMode == "primary" then
				buildLayer = "foreground"
			elseif fireMode == "alt" then
				buildLayer = "background"
			end

			-- starbound wants all the blocks individually instead of being able to input a poly
			buildPoints = poly.translate(blocksFromPoly(buildPoly),vec2.add(aimBlock,offset))

			-- placing the blocks
			for _, point in ipairs(buildPoints) do
				if not blocksToPlace[point] and not world.tileIsOccupied(point,buildLayer) then
					blocksToPlace[point] = {layer = buildLayer,material = buildMaterial, color = buildColor, time = tickCounter}
				end
				-- TODO: add color to block table
				--world.setMaterialColor(point,buildLayer,buildColor)
			end
		end

		if shiftHeld and controls.left then -- block picking
			shiftLeftPressed = true
		else
			if shiftLeftPressed then
				-- default to the foreground block, only do background if there isn't a foreground (because user cant see the background anyways)
				-- TODO: picking water
				local scannedMaterial = world.material(activeItem.ownerAimPosition(),"foreground")
				local materialHueshift = 0

				if scannedMaterial then
					buildMaterial = scannedMaterial
					buildColor = world.materialColor(activeItem.ownerAimPosition(),"foreground")
					materialHueshift = world.materialHueShift(activeItem.ownerAimPosition(),"foreground")
				else
					scannedMaterial = world.material(activeItem.ownerAimPosition(),"background")

					if scannedMaterial then
						buildMaterial = scannedMaterial
						buildColor = world.materialColor(activeItem.ownerAimPosition(),"background")
						materialHueshift = world.materialHueShift(activeItem.ownerAimPosition(),"background")
					end
				end

				buildImage = "/assetmissing.png"

				if buildMaterial --[[ and buildMaterial ~= nil ]] then

					local materialPath = root.materialConfig(buildMaterial).path
					local materialConfig = root.assetJson(materialPath)
					local renderTemplate = root.assetJson(materialConfig.renderTemplate)

					local materialImage = materialConfig.renderParameters.texture
					-- image processing junk to make an absolute or relative file path
					if (materialImage:sub(1,1) ~= "/") then -- if it starts with a slash then it's an absolute path and we're done
						local lastSlash = materialPath:match'^.*()/' -- stackoverflow credit to https://stackoverflow.com/users/1847592/egor-skriptunoff for the fast finding of last slash
						materialImage = materialPath:sub(1,lastSlash) .. materialImage -- make it the same as the .material file's path with the image added
					end


					local numVariants = materialConfig.renderParameters.variants
					local muliColored = materialConfig.renderParameters.multiColored

					

					if (materialConfig.renderTemplate == "/tiles/classicmaterialtemplate.config") then -- only testing basic render template for now
						local pieceConfig = renderTemplate.pieces.base
						local colorStride = pieceConfig.colorStride
						local variantStride = pieceConfig.variantStride
						local imageSize = root.imageSize(materialImage)
						local cropSize = pieceConfig.textureSize
						local cropPos = pieceConfig.texturePosition
						cropPos = vec2.add(cropPos,vec2.mul(colorStride,buildColor)) -- shift down based on color
						for i = 1, 6 do -- random variant for each face
							local variant = math.random(1,numVariants)
							local variantOffset = vec2.mul(variantStride,variant-1)
							local blockImage = materialImage .. "?crop=" .. tostring(cropPos[1] + variantOffset[1]) .. ";" .. tostring(imageSize[2] - (cropPos[2] + cropSize[2]) + variantOffset[2]) .. ";" .. tostring(cropPos[1] + cropSize[1] + variantOffset[1]) .. ";" .. tostring(imageSize[2] - (cropPos[2]) + variantOffset[2])
							boxImages[i] = blockImage
						end
						
						buildImage = boxImages[1]
					end

					activeItem.setInventoryIcon(buildImage)

				end
			end
			shiftLeftPressed = false
		end


		spawnPoly = poly.translate(buildPoly,vec2.add(aimBlock,offset))

		for i,v in ipairs(spawnPoly) do
			world.debugLine(manipulatorTipPosition,spawnPoly[i],"green")
		end

		local polyMinX = extrInList(spawnPoly,"min","x")
		local polyMaxX = extrInList(spawnPoly,"max","x")
		local polyMinY = extrInList(spawnPoly,"min","y")
		local polyMaxY = extrInList(spawnPoly,"max","y")

		for x = polyMinX, polyMaxX, 1 do
			world.debugLine({x,polyMinY},{x,polyMaxY},"green")
		end

		for y = polyMinY, polyMaxY, 1 do
			world.debugLine({polyMinX,y},{polyMaxX,y},"green")
		end


		if shiftHeld and controls.up then -- size increase
			shiftUpPressed = true
		else
			if shiftUpPressed then
				buildSize = buildSize + 1
			end
			shiftUpPressed = false
		end

		if shiftHeld and controls.down then -- size decrease
			shiftDownPressed = true
		else
			if shiftDownPressed then
				buildSize = math.max(buildSize - 1,1)
			end
			shiftDownPressed = false
		end
	end

	-- cube stuff
	if mode == "mine" then
		animator.scaleTransformationGroup("block",0)
	elseif mode == "build" then
		animator.resetTransformationGroup("block")
		animator.rotateTransformationGroup("block",-self.angle)
		for i, face in ipairs(cube) do
			cube[i].points = rotate(face.points,math.rad(0.7),math.rad(1.0),math.rad(0))
		end

		local blockTranslation = {2,0}
		blockTranslation = vec2.add(blockTranslation,vec2.rotate({0,math.sin(bobCounter) * bobIntensity},-self.angle))
		bobCounter = bobCounter + bobFrequency

		animator.translateTransformationGroup("block",blockTranslation)


		for i, face in ipairs(cube) do
			cube[i].image = buildImage
		end

		render3dFaces(cube)
	end

	-- placing blocks from the table
	for k, v in pairs(blocksToPlace) do
		if world.tileIsOccupied(k,v.layer) or tickCounter > v.time + placeTimeout then -- have blocks timeout after x seconds
			blocksToPlace[k] = nil
		else
			world.placeMaterial(k,v.layer,v.material,0,true)
		end
	end
end

function joinMyTables(t1, t2)

   for k,v in ipairs(t2) do
      table.insert(t1, v)
   end 

   return t1
end

-- save stuff to the json so it remembers
function uninit()
	activeItem.setInstanceValue("lastBuildMaterial",buildMaterial)
	activeItem.setInstanceValue("lastBuildColor",buildColor)
	activeItem.setInstanceValue("lastBuildImage",buildImage)
	activeItem.setInstanceValue("lastMode",mode)
	activeItem.setInstanceValue("boxImages",boxImages)
end

-- my boilerplate aimable item code
function updateAim()
	local aimPos = activeItem.ownerAimPosition()
	self.angle, self.direction = activeItem.aimAngleAndDirection(0,aimPos)
	activeItem.setArmAngle(self.angle)
	activeItem.setFacingDirection(self.direction)
end

-- good ol' pythagoras
function calcDist(vectorA,vectorB)
    local xDist = vectorA[1] - vectorB[1]
    local yDist = vectorA[2] - vectorB[2]
    return math.sqrt(xDist ^ 2 + yDist ^ 2)
end

-- dumb stuff for block snapping
function getAimBlock()
	local aimPos = activeItem.ownerAimPosition()
	local x = aimPos[1]
	local y = aimPos[2]
	local offset = {0,0}

	if x - math.floor(x) <= 0.5 then
		x = math.floor(x)
		offset[1] = 0.5
	else
		x = math.ceil(x)
		offset[1] = -0.5
	end
	if y - math.floor(y) <= 0.5 then
		y = math.floor(y)
		offset[2] = 0.5
	else
		y = math.ceil(y)
		offset[2] = -0.5
	end
	return {x,y}, offset
end

-- literally goes through a rectangular poly and returns all the blocks from it
function blocksFromPoly(inpPoly)
	local minX = extrInList(inpPoly,"min","x")
	local minY = extrInList(inpPoly,"min","y")
	local maxX = extrInList(inpPoly,"max","x")
	local maxY = extrInList(inpPoly,"max","y")

	local returnList = {}

	for ix = minX,maxX-1,1 do
		for iy = minY,maxY-1,1 do
			table.insert(returnList,{ix,iy})
		end
	end

	return returnList
end

-- finds the outer bounds of a poly
function extrInList(inpList,minOrMax,xOrY)
	local pos = nil
	if xOrY == "x" then
		pos = 1
	elseif xOrY == "y" then
		pos = 2
	end
	local result = inpList[1][pos]
	for _, vec in ipairs(inpList) do
		if minOrMax == "min" then
			result = math.min(result,vec[pos])
		elseif minOrMax == "max" then
			result = math.max(result,vec[pos])
		end
	end
	return result
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function render3dFaces(faces)
    local faceZs = {}
    for i, v in ipairs(faces) do
        table.insert(faceZs,{i,(v.points[1][3]+v.points[2][3]+v.points[3][3]+v.points[4][3])/4})
        local zSort = function(a,b)
            return a[2] > b[2]
        end
        table.sort(faceZs,zSort)
    end


    for i, faceDat in ipairs(faceZs) do
        if i <= 3 then -- only render 3 frontmost faces
            local v = faces[faceDat[1]].points

            local topAngle = math.atan(v[2][2]-v[1][2],v[2][1]-v[1][1])
            local sideAngle = math.atan(v[2][2]-v[3][2],v[2][1]-v[3][1])
            


            local topWidth = math.sqrt((v[1][2]-v[2][2])^2+(v[1][1]-v[2][1])^2)
            local sideHeight = math.sqrt((v[2][2]-v[3][2])^2+(v[2][1]-v[3][1])^2)
            
            local centerPos = vec2.div({v[1][1]+v[2][1]+v[3][1]+v[4][1],v[1][2]+v[2][2]+v[3][2]+v[4][2]},4)
            

            local tempFace = {} -- make a copy of the face to work backwards with
            for j, w in ipairs(v) do
                tempFace[j]={w[1],w[2]}
            end
            for j, w in ipairs(tempFace) do
                tempFace[j] = vec2.add(w,vec2.mul(centerPos,-1))
            end
            for j, w in ipairs(tempFace) do
                tempFace[j] = vec2.rotate(w,-topAngle)
            end
            local tempXCenter = (tempFace[2][1]+tempFace[1][1])/2
            local tempY = tempFace[1][2]
            local XshearAmount = tempXCenter/tempY

        
            animator.resetTransformationGroup(tostring(i))
			local curImage = boxImages[faceDat[1]]
            local cubeSize = math.sqrt((v[1][1]-v[2][1])^2+(v[1][2]-v[2][2])^2+(v[1][3]-v[2][3])^2)
            local imageSize = root.imageSize(curImage)[1]/8
            animator.transformTransformationGroup(tostring(i),cubeSize/imageSize,0,0,cubeSize/imageSize,0,0) -- make image line up with cube size



            animator.transformTransformationGroup(tostring(i),1,0,0,tempY/cubeSize*2,0,0)
            animator.transformTransformationGroup(tostring(i),topWidth/cubeSize,0,0,1,0,0)
            animator.transformTransformationGroup(tostring(i),1,XshearAmount,0,1,0,0)
            animator.transformTransformationGroup(tostring(i), math.cos(-topAngle),math.sin(-topAngle),-math.sin(-topAngle),math.cos(-topAngle),0,0)
            animator.transformTransformationGroup(tostring(i),1,0,0,1,centerPos[1],centerPos[2]) -- line up center of square with correct position

            
            animator.setGlobalTag(tostring(i),curImage)
        end
    end
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
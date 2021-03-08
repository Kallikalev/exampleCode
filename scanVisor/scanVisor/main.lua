local frameNum = 0
local frameCount = 6
local frameSpeed = 0.25

function aInit()
end

function aUpdate()
	frameNum = frameNum + frameSpeed
	if frameNum > frameCount - 1 + 0.5 - math.abs(frameSpeed) or frameNum < math.abs(frameSpeed) then
		frameSpeed = frameSpeed * -1
	end


	for _, entity in ipairs(world.entityQuery(world.entityPosition(player.id()),200,{includedTypes={"player","monster","npc","projectile"}})) do
		local entityName = world.entityName(entity)
		if string.len(entityName) < 1 then
			entityName = world.entityTypeName(entity)
		end
		local entityPosition = world.entityPosition(entity)
		addText(tostring(entity),vec2.add(entityPosition,{0.8,-1.8}),"middle",0.4)
		addText(entityName or "",vec2.add(entityPosition,{0.8,-2.3}),"middle",0.4)
		if world.entityCanDamage(entity,player.id()) then -- spawn reticle on hostile entities
			localAnimator.spawnParticle({
				type = "textured",
				image = "/scanVisor/reticle.png:" .. tostring(math.floor(frameNum))
			},
			entityPosition)
		end

		local CID = math.floor((entity - 65535) / -65536)
		addText("^shadow;^orange;CID: ^white;" .. CID,vec2.add(entityPosition,{0.8,-2.8}),"middle",0.4)

		if world.entityType(entity) == "player" then
			local playerSpecies = world.entitySpecies(entity) -- finds the player's species
			local playerHealthTable = world.entityHealth(entity) -- finds the player's health and max health in a table of two values
			local playerHealth = math.floor(playerHealthTable[1]) -- pulls the first value, the current health, into a variable
			local playerHealthMax = math.floor(playerHealthTable[2]) -- pulls the second value, the max health, into a variable
			local playerPixels = world.entityCurrency(entity,"money") -- finds the player's pixel count
			local primaryItemDescriptor = world.entityHandItemDescriptor(entity,"primary") -- find an item descriptor of the player's primary hand item
			local primaryItemName = nil -- define a variable to be changed for the name
			if primaryItemDescriptor == nil then -- checks if the player's hand is empty
				primaryItemName = "<no primary>" -- sets the text accordingly
			else
				primaryItemName = primaryItemDescriptor.parameters.shortdescription -- sets the text to be the short description paramter of the item
				if primaryItemName == nil then -- checks if that didn't work (meaning that the item didnt have a short description paramter)
					primaryItemName = primaryItemDescriptor.name -- sets the text to be the item name (like rarebroadsword) instead
				end
			end
			-- exact same thing as with primary item
			local altItemDescriptor = world.entityHandItemDescriptor(entity,"alt")
			local altItemName = nil
			if altItemDescriptor == nil then
				altItemName = "<no alt>"
			else
				altItemName = altItemDescriptor.parameters.shortdescription
				if altItemName == nil then
					altItemName = altItemDescriptor.name
				end
			end
			-- end
			local playerUuid = world.entityUniqueId(entity) -- finds the player's uuid
			

			addText("^shadow;^green;" .. playerSpecies,vec2.add(entityPosition,{0.8,-3.3}),"middle",0.4)
			addText("^shadow;^red;" .. playerHealth .. "^white; / ^red;" .. playerHealthMax .. " ^white;hp",vec2.add(entityPosition,{0.8,-3.8}),"middle",0.4)
			addText("^shadow;^yellow;" .. playerPixels .. " ^white;pixels",vec2.add(entityPosition,{0.8,-4.3}),"middle",0.4)
			addText("^shadow;^blue;" .. primaryItemName .. " ^white;, ^red;" .. altItemName,vec2.add(entityPosition,{0.8,-4.8}),"middle",0.4)
			addText("^shadow;^orange;\"" .. playerUuid .. "\"",vec2.add(entityPosition,{0.8,-5.3}),"middle",0.4)
			
		end
	end
end

function aUninit()
end

function addText(_inputString,_position,_align,_scale)
	if not validateUTF8(_inputString) then
		_inputString = "Invalid UTF-8"
	end	
	if _align == "right" then
		_inputString = _inputString .. "^clear;" .. _inputString
	elseif _align == "left" then
		_inputString = "^clear;" .. cutColors(_inputString) .. "^reset;" .. _inputString
	end
	localAnimator.spawnParticle(
		{
			type = "text",
			text = _inputString,
			fullbright = true,
			size = _scale or 1,
			layer = "front",
			timeToLive = 0
		},
		_position
	)
end

function validateUTF8(str)
  local i, len = 1, #str
  while i <= len do
    if     i == string.find(str, "[%z\1-\127]", i) then i = i + 1
    elseif i == string.find(str, "[\194-\223][\128-\191]", i) then i = i + 2
    elseif i == string.find(str,        "\224[\160-\191][\128-\191]", i)
        or i == string.find(str, "[\225-\236][\128-\191][\128-\191]", i)
        or i == string.find(str,        "\237[\128-\159][\128-\191]", i)
        or i == string.find(str, "[\238-\239][\128-\191][\128-\191]", i) then i = i + 3
    elseif i == string.find(str,        "\240[\144-\191][\128-\191][\128-\191]", i)
        or i == string.find(str, "[\241-\243][\128-\191][\128-\191][\128-\191]", i)
        or i == string.find(str,        "\244[\128-\143][\128-\191][\128-\191]", i) then i = i + 4
    else
      return false, i
    end
  end

  return true
end
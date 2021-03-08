local ini = init or function() end
local upd = update or function() end
local unini = uninit or function() end

local modeSystemsConfig = nil
local lastAnimationState = false

local counter = 60
local frame = 1
local item = nil

function init()
	ini()
	modeSystemsConfig = root.assetJson("/modeSystems/config.json").modes
	item = root.assetJson("/modeSystems/deployment/noclip/template.json")
	player.setEquippedItem("backCosmetic",nil)
end

function update(...)
	upd(...)
	local systemMode = status.statusProperty("systemMode",nil)
	if systemMode then
		local backAnimationActive = status.statusProperty("noclipActive",false) and modeSystemsConfig[systemMode].noclip.backAnimationActive
		if lastAnimationState ~= backAnimationActive then
			if backAnimationActive then

				local currentItem = player.equippedItem("backCosmetic")
				player.setEquippedItem("backCosmetic")
				if not player.hasItem(currentItem,true) then
					functionalSlotName = "back"
					functionalItem = player.equippedItem("back")
					if functionalItem == nil then
						player.setEquippedItem("back",{count=1,name="baroncapeback",parameters={}})
					end
					player.giveItem(currentItem)
					if functionalItem == nil then
						player.setEquippedItem("back")
					end
				end
			else
			--restore back cosmetic item from clothing json
				if modeSystemsConfig[systemMode].clothing.clothingActive and modeSystemsConfig[systemMode].clothing.clothesConfig.backCosmetic ~= nil then
					local clothingBackCosmetic = modeSystemsConfig[systemMode].clothing.clothesConfig.backCosmetic
					if clothingBackCosmetic.name == nil then
						clothingBackCosmetic = nil
					end
					player.setEquippedItem("backCosmetic",clothingBackCosmetic)
				else
					player.setEquippedItem("backCosmetic",nil)
				end
			end
		end
		if backAnimationActive then
			local frequency = modeSystemsConfig[systemMode].noclip.animationCycleSpeed
			local frames = modeSystemsConfig[systemMode].noclip.backAnimationFrames
			if counter > 60 / frequency then
				frame = frame + 1
				if frame > #frames then
					frame = 1
				end
				local baseImage = modeSystemsConfig[systemMode].noclip.backAnimationBaseImage
				local currentFrame = frames[frame]
				local directives = modeSystemsConfig[systemMode].noclip.backAnimationDirectives
				local currentImage = "?setcolor=ffffff?replace;00000000=ffffff;ffffff00=ffffff?setcolor=ffffff?scalenearest=1?blendmult=" .. baseImage .. ":" .. currentFrame .. "?replace;ffffffff=ffffff00" .. directives
				item.parameters.directives = currentImage
				player.setEquippedItem("backCosmetic",item)
				counter = 0
			else
				counter = counter + 1
			end
		end
		lastAnimationState = backAnimationActive
	end
end

function uninit()
	unini()
end
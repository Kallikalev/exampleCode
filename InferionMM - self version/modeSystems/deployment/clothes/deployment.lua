local ini = init or function() end
local upd = update or function() end
local unini = uninit or function() end

local modeSystemsConfig = nil
local lastMode = nil

local placeHolderItems = {
	head = "novatier1head",
	chest = "novatier1chest",
	legs = "novatier1pants",
	back = "baroncapeback"
}

function init()
	ini()
	modeSystemsConfig = root.assetJson("/modeSystems/config.json").modes
end


function update(...)
	upd(...)
	local systemMode = status.statusProperty("systemMode",nil)
	if systemMode and systemMode ~= lastMode then
		updateClothing(systemMode)
	end
	lastMode = systemMode
end

function uninit()
	unini()
end

function updateClothing(systemMode)
	if modeSystemsConfig[systemMode].clothing.clothingActive then
		local clothes = modeSystemsConfig[systemMode].clothing.clothesConfig
		for key, contents in pairs(clothes) do
			if not (key == "backCosmetic" and status.statusProperty("noclipActive",false)) then
				local currentItem = player.equippedItem(key)
				if contents.name ~= nil then
					player.setEquippedItem(key,contents)
				else
					player.setEquippedItem(key,nil)
				end
				if not player.hasItem(currentItem,true) then
					local cosmeticStartChar = string.find(key,"Cosmetic")
					if cosmeticStartChar ~= nil then  -- stop items from landing in functional slot
						functionalSlotName = string.sub(key,1,cosmeticStartChar - 1)
						functionalItem = player.equippedItem(functionalSlotName)
						if functionalItem == nil then
							player.setEquippedItem(functionalSlotName,{count=1,name=placeHolderItems[functionalSlotName],parameters={}})
						end
					end
					player.giveItem(currentItem)
					if functionalItem == nil then
						player.setEquippedItem(functionalSlotName)
					end
				end
			end
		end
	end
end
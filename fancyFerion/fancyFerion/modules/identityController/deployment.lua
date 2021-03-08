local ini = init or function() end
local upd = update or function() end
local unini = uninit or function() end

function init()
	ini()
end


function update(...)
	upd(...)
	if status.statusProperty("fancyFerionActive",false) then
		local newClothing = status.statusProperty("fancyFerionClothes",nil)
		if newClothing ~= nil then
			for k, v in pairs(newClothing) do
				if v == "none" then
					player.setEquippedItem(k,nil)
				else
					player.setEquippedItem(k,v)
				end
			end
			status.setStatusProperty("fancyFerionClothes",nil)
		end
	end
end

function uninit()
	unini()
end
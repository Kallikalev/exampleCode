local ini = init or function() end
local upd = update or function() end
local unini = uninit or function() end

function init()
	ini()
	message.setHandler("openInterface", function(_,clientSender,config)
		if clientSender then
			player.interact("ScriptPane",config)
		end
	end)

	-- set default mode
	if status.statusProperty("systemMode",nil) == nil then
		status.setStatusProperty("systemMode","blank")
		player.makeTechAvailable("mode")
		player.enableTech("mode")
		player.equipTech("mode")
	else
		local modeSystemsConfig = root.assetJson("/modeSystems/config.json").modes
		if modeSystemsConfig[status.statusProperty("systemMode",nil)] == nil then
			status.setStatusProperty("systemMode","blank")
		end
	end
end

function update(...)
	upd(...)
end

function uninit()
	unini()
end


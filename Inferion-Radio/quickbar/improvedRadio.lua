local config = root.assetJson("/interface/improvedRadio.json")
local gui = config.gui

function module.openInterface()
	-- if status.statusProperty("impRadioCanOpen",true) then
		player.interact("ScriptPane", config)
	-- end
end
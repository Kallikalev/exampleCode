function init()
	require "/customEmotes/keybinds.lua"

	Bind.create("specialThree left=false right=false up=false down=false",openWheel,false)
end

function update(args)
	args.aimPosition = tech.aimPosition()
	status.setStatusProperty("emoteArgs",args)
end

function uninit()
	status.setStatusProperty("emoteArgs",nil)
end

function openWheel()
	status.setStatusProperty("emoteWheelOpen",not status.statusProperty("emoteWheelOpen",false))
end
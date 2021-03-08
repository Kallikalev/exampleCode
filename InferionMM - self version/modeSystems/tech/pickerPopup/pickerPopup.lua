function pickerPopupInit()
	Bind.create("specialThree left",doPopup,false)
end

function pickerPopupUpdate(args)

end

function pickerPopupUninit()
end

function doPopup()
	if not status.statusProperty("pickerPopupOpen",false) then
		world.sendEntityMessage(entity.id(),"openInterface",root.assetJson("/modeSystems/deployment/pickerPopup/interface.json"))
	end
end
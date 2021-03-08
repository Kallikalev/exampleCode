local listPath = "scrollArea.itemList"

local initialized = false

function init()
	status.setStatusProperty("pickerPopupOpen",true)
	widget.clearListItems(listPath)

	for key, contents in pairs(root.assetJson("/modeSystems/config.json").modes) do
		local newItem = widget.addListItem(listPath)
		local newItemPath = listPath .. "." .. newItem
		widget.setText(newItemPath .. ".name",contents.name)
		widget.setData(newItemPath,key)
		if key == status.statusProperty("systemMode",nil) then
			widget.setListSelected(listPath,newItem)
		end
	end
end

function update()
	initialized = true
end

function uninit()
	status.setStatusProperty("pickerPopupOpen",false)
end

function listItemSelected()
	if initialized then
		local selectedItem = widget.getListSelected(listPath)
		local data = widget.getData(listPath .. "." .. selectedItem)
		status.setStatusProperty("systemMode",data)
	end
end
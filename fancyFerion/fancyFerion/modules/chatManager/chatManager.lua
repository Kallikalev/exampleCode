currentChatPreset = 1

local chatTimer = 0
local chatSpeed = 0.02

function chatManagerInit()
	chatPresets = root.assetJson("/fancyFerion/modules/chatManager/chatPresets.json")
end

function chatManagerUpdate(args)
	if dll.chatFocused() then
		local currentChat = dll.currentChat()
		if currentChat ~= "" then
			currentChat = getCustomChat(currentChat,chatPresets[currentChatPreset])
			if chatPresets[currentChatPreset].preview then
				dll.addChatMessage(currentChat)
			end
			dll.setChatMessage(currentChat)
		end
	end

	chatTimer = chatTimer + chatSpeed
end

function chatManagerUninit()
end

function getCustomChat(message,preset)
	if preset.type == "none" then
		return message
	elseif preset.type == "gradient" then
		local colors = preset.colors
		local endMessage = ""
		for i = 1, message:len() do
			local percentage = ((i-1)/(message:len()-1)+chatTimer)%1
			local newColor = color.transHex(colors[1],colors[2],percentage)
			endMessage = endMessage .. "^#" .. newColor .. ";" .. message:sub(i,i)
		end
		return endMessage
	else
		sb.logError("Fancyferion: Chat type " .. tostring(preset.type) .. " is not valid")
	end
end
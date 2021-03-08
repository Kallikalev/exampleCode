local ini = init or function() end
local upd = update or function() end
local unini = uninit or function() end

local modeSystemsConfig = nil
local lastMode = nil

local modeTechActiveLast = false

function init()
	ini()
	modeSystemsConfig = root.assetJson("/modeSystems/config.json").modes
end

function update(...)
	upd(...)

	if status.statusProperty("modeTechActive",false) ~= modeTechActiveLast then
		status.clearEphemeralEffects()
	end

	local systemMode = status.statusProperty("systemMode",nil)
	if systemMode and systemMode ~= lastMode then
		updateEffects(systemMode)
	end

	lastMode = systemMode
	modeTechActiveLast = status.statusProperty("modeTechActive",false)
end

function uninit()
	unini()
end

function updateEffects(systemMode)
	status.clearEphemeralEffects()
	local effects = modeSystemsConfig[systemMode].statusEffects
	for i, effect in ipairs(effects) do
		status.addEphemeralEffect(effect,9999999)
	end
end
local requirePrefix = "/modeSystems/tech/%s/%s.lua"
local requireList = {
	"pickerPopup",
	"noclip",
	"noclipClassic",
	"blink",
	"rotSize",
	"sit",
	"passiveParticles",
	"directives"
}
for i, v in ipairs(requireList) do
	require(string.format(requirePrefix,v,v))
end

function init()
	require "/scripts/keybinds.lua"
	require "/scripts/techDirectives.lua"

	self.modeSystemsConfig = root.assetJson("/modeSystems/config.json")
	self.savedPos = mcontroller.position()
	self.savedSize = 1
	self.savedRotation = 0
	self.savedState = "Stand"
	self.stateControlled = false

	self.noclipActive = false
	self.noclipClassicActive = false
	self.sitActive = false

	for i, v in ipairs(requireList) do
		_ENV[v .. "Init"]()
	end

	status.setStatusProperty("modeTechActive",true)
end

function update(args)
	-- for other scripts to use
	args.aimPosition = tech.aimPosition()
	status.setStatusProperty("techArgs",args)

	self.mode = status.statusProperty("systemMode","blank")
	self.stateControlled = false

	for i, v in ipairs(requireList) do
		_ENV[v .. "Update"](args)
	end

	if self.stateControlled then
		tech.setParentState(self.savedState)
	else
		tech.setParentState()
	end
end

function uninit()
	for i, v in ipairs(requireList) do
		_ENV[v .. "Uninit"]()
	end

	tech.setParentState()

	status.setStatusProperty("modeTechActive",false)
end

function spawnParticle(_position,_specification,_delay) -- made by inferion (which is why it's trash)
	local _delay = _delay or 0
	local periodicActions = {}
	if type(_specification) == "array" then
		for i, v in ipairs(_specification) do
		local newAction = {
			time = _delay[i],
			action = "particle",
			specification = v
		}
		newAction["repeat"] = false
		table.insert(periodicActions,
			newAction
		)
		end
	else
		local newAction = {
			time = _delay,
			action = "particle",
			specification = _specification
		}
		newAction["repeat"] = false
		table.insert(periodicActions,
			newAction
		)
	end
	world.spawnProjectile("boltguide", _position, entity.id(), {0, 0}, false, {
		damageType = "NoDamage",
		processing = "?setcolor=000000?replace;000000=ffffff00",
		movementSettings = {
			collisionPoly = jarray()
		},
		timeToLive = _delay * 2 + 0.2,
		periodicActions = periodicActions,
		actionOnReap = jarray()
		-- actionOnReap = {{
		-- 	action = "particle",
		-- 	specification = _specification
		-- }}
	})
end
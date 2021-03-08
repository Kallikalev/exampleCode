require "/scripts/vec2.lua"

local particleCounter = 0

local passiveConfig = nil


function passiveParticlesInit()
end

function passiveParticlesUpdate()
	passiveConfig = self.modeSystemsConfig.modes[self.mode].passiveParticleConfig
	if passiveConfig.particlesActive then
		particleCounter = particleCounter + 1/60
		if particleCounter % (self.modeSystemsConfig.modes[self.mode].passiveParticleConfig.particleRate + 1/60) < 1/60 then
			passiveParticleEffect()
		end
	end
end

function passiveParticlesUninit()
end

function passiveParticleEffect()
	if passiveConfig.particlesActive then
		local particleConfig = nil
		if passiveConfig.particleSpecification[1] ~= nil then
			particleConfig = passiveConfig.particleSpecification[math.random(#passiveConfig.particleSpecification)]
		else
			particleConfig = passiveConfig.particleSpecification
		end
		local particleSpawnPos = getParticlePos(passiveConfig.particlePos)
		particleSpawnPos = vec2.add(particleSpawnPos,mcontroller.position())

		spawnParticle(particleSpawnPos,particleConfig)
	end
end

function spawnParticle(_position,_specification) -- made by inferion (which is why it's trash)
	world.spawnProjectile("boltguide", _position, entity.id(), {0, 0}, true, {
		damageType = "NoDamage",
		movementSettings = {
			collisionPoly = jarray()
		},
		processing = "?setcolor=000000?replace;000000=ffffff00",
		timeToLive = 0,
		actionOnReap = {{
			action = "particle",
			specification = _specification
		}}
	})
end

function getParticlePos(posStatement)
	if posStatement[1] ~= nil and posStatement[2] ~= nil then
		-- if position is a single point
		if type(posStatement[1]) == "number" and type(posStatement[2]) == "number" then
			return posStatement
		-- if position is a range
		elseif type(posStatement[1] == "table" and type(posStatement[2]) == "table") then
			return {precRand(posStatement[1][1],posStatement[2][1]),precRand(posStatement[1][2],posStatement[2][2])}
		end
	elseif posStatement["right"] ~= nil and posStatement["left"] ~= nil then
		if mcontroller.facingDirection() == 1 then
			return getParticlePos(posStatement.right)
		else
			return getParticlePos(posStatement.left)
		end
	end
	return {0,0}
end

function precRand(i1,i2)
	return math.random(i1*10000,i2*10000)/10000
end
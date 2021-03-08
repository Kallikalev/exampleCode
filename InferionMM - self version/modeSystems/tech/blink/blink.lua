require "/scripts/vec2.lua"

function blinkInit()
	Bind.create("specialOne=true up=false down=false",doBlink,false)
end

function blinkUpdate(args)
end

function blinkUninit()
	mcontroller.controlParameters()
end

function doBlink()
	local aimPos = tech.aimPosition()
	local currentPos = mcontroller.position()

	createBlinkEffect(currentPos)
	mcontroller.setPosition(aimPos)
	self.savedPos = mcontroller.position()
	createBlinkEffect(currentPos)
end

function createBlinkEffect(position)
	local blinkConfig = self.modeSystemsConfig.modes[self.mode].blink
	if blinkConfig.particlesActive then
		for _=1, blinkConfig.numParticles do
			local particleConfig = nil
			if blinkConfig.particleSpecification[1] ~= nil then
				particleConfig = blinkConfig.particleSpecification[math.random(#blinkConfig.particleSpecification)]
			else
				particleConfig = blinkConfig.particleSpecification
			end
			local particleSpawnPos = getParticlePos(blinkConfig.particlePos)
			particleSpawnPos = vec2.add(particleSpawnPos,position)

			spawnParticle(particleSpawnPos,particleConfig)
		end
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
require "/tech/doubletap.lua"
require "/scripts/vec2.lua"
require "/scripts/poly.lua"

local maximumDoubleTapTime = 0.25

local noclipVelocity = {0,0}

local noclipParameters = {
	collisionEnabled = false,
	mass = 0,
	physicsEffectCategories = jarray(),
	collisionPoly = jarray()
}
local defaultParameters = {
	collisionEnabled = true,
	physicsEffectCategories = {"player"}
}
local moveSpeed = 0.5
local frictionMul = 0.98

local bobCounter = 0
local bobIntensity = 30 -- higher = larger bob
local bobFrequency = 0.04 -- higher = faster bob
local bobBoundary = 5 -- how slow you need to be going for bob to be applied

local particleCounter = 0

local beingControlled = false
local targetPosition = {0,0}


function noclipInit()
	self.doubleTap = DoubleTap:new({"jump"},maximumDoubleTapTime,function() -- double tap setup
		if self.noclipActive then
			self.noclipActive = false
			mcontroller.setVelocity(noclipVelocity)
		else
			self.noclipActive = true
			self.noclipClassicActive = false
			self.sitActive = false
			self.savedPos = mcontroller.position()
			noclipVelocity = mcontroller.velocity()
		end
	end)

	message.setHandler("controlInferion",function(_, clientSender, newTargetPosition)
		self.noclipActive = true
		self.noclipClassicActive = false
		self.sitActive = false
		self.savedPos = mcontroller.position()
		targetPosition = newTargetPosition
		noclipVelocity = {0,0}
		beingControlled = true
	end)

end

function noclipUpdate(args)
	self.doubleTap:update(args.dt, args.moves)

	local systemMode = status.statusProperty("systemMode",nil)

	if self.noclipActive then
		mcontroller.controlParameters(noclipParameters)

		if beingControlled then
			local currentPos = mcontroller.position()
			if calcDist(currentPos,targetPosition) < 1 then
				beingControlled = false
				noclipVelocity = {0,0}
				self.savedPos = targetPosition
				targetPosition = {0,0}
			else
				if currentPos[1] < targetPosition[1] then
					args.moves.right = true
				end
				if currentPos[1] > targetPosition[1] then
					args.moves.left = true
				end
				if currentPos[2] < targetPosition[2] then
					args.moves.up = true
				end
				if currentPos[2] > targetPosition[2] then
					args.moves.down = true
				end
			end
		end

		if args.moves["up"] then
			noclipVelocity[2] = noclipVelocity[2] + moveSpeed
		end
		if args.moves["down"] then
			noclipVelocity[2] = noclipVelocity[2] - moveSpeed
		end
		if args.moves["left"] then
			noclipVelocity[1] = noclipVelocity[1] - moveSpeed
		end
		if args.moves["right"] then
			noclipVelocity[1] = noclipVelocity[1] + moveSpeed
		end

		-- bob stuff
		if calcDist({0,0},noclipVelocity) < bobBoundary then
			bobCounter = bobCounter + bobFrequency
			self.savedPos = vec2.add(self.savedPos,{0,math.sin(bobCounter) / bobIntensity})
		else
			bobCounter = math.pi
		end

		-- particles
		if self.modeSystemsConfig.modes[self.mode].noclip.particlesActive then
			local particleConfig = self.modeSystemsConfig.modes[self.mode].noclip

			particleCounter = particleCounter + 1/60
			if particleCounter > particleConfig.particleRate then
				particleCounter = 0

				local currentParticle = nil
				local facingDirection = nil
				local particlePosition = {0,0}

				if particleConfig.particleSpecification[1] ~= nil then
					currentParticle = particleConfig.particleSpecification[math.random(#particleConfig.particleSpecification)]
				else
					currentParticle = particleConfig.particleSpecification
				end

				particlePosition = getParticlePos(particleConfig.particlePos)

				spawnParticle(vec2.add(particlePosition,mcontroller.position()),currentParticle)

			end
		end

		-- applying everything

		self.savedPos = vec2.add(self.savedPos,vec2.div(noclipVelocity,60))
		mcontroller.setPosition(self.savedPos)
		self.stateControlled = true
		self.savedState = self.modeSystemsConfig.modes[systemMode].noclip.state
		noclipVelocity = vec2.mul(noclipVelocity,frictionMul)
		status.setStatusProperty("noclipActive",true)
	else
		defaultParameters.standingPoly = poly.scale({{-0.75, -2.0}, {-0.35, -2.5}, {0.35, -2.5}, {0.75, -2.0}, {0.75, 0.65}, {0.35, 1.22}, {-0.35, 1.22}, {-0.75, 0.65}},self.savedSize)
		defaultParameters.crouchingPoly = poly.scale({{-0.75, -2.0}, {-0.35, -2.5}, {0.35, -2.5}, {0.75, -2.0}, {0.75, -1.0}, {0.35, -0.5}, {-0.35, -0.5}, {-0.75, -1.0}},self.savedSize)
		mcontroller.controlParameters(defaultParameters)
		status.setStatusProperty("noclipActive",false)
	end
end

function noclipUninit()
	mcontroller.controlParameters()
	status.setStatusProperty("noclipActive",false)
end

function calcDist(vectorA,vectorB)
    local xDist = vectorA[1] - vectorB[1]
    local yDist = vectorA[2] - vectorB[2]
    return math.sqrt(xDist ^ 2 + yDist ^ 2)
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
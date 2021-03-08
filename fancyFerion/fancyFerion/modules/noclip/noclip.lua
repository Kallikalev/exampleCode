noclipActive = false

local moveSpeed = 0.5
local frictionMul = 0.98
local noclipVelocity = {0,0}

local defaultParameters = {
	collisionEnabled = true,
	physicsEffectCategories = {"player"}
}

local noclipParameters = {
	gravityEnabled = false,
	collisionEnabled = false,
	mass = 0,
	physicsEffectCategories = jarray(),
	collisionPoly = jarray()
}

function noclipInit()
	Bind.create("specialOne=true up=false down=false left=true right=false",toggleNoclip,false)
end

function noclipUpdate(args)
	if noclipActive then


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


		savedPos = vec2.add(savedPos,vec2.div(noclipVelocity,60))
		noclipVelocity = vec2.mul(noclipVelocity,frictionMul)


		mcontroller.setVelocity({0,0})
		tech.setParentState("fly")
		mcontroller.setPosition(savedPos)
		mcontroller.controlParameters(noclipParameters)


		noclipCounter = noclipCounter + 1
	end
end

function noclipUninit()
	mcontroller.setRotation(0)
	tech.setParentState()
	mcontroller.controlParameters(defaultParameters)
end

function toggleNoclip()
	noclipActive = not noclipActive
	if noclipActive then
		noclipCounter = 0
		noclipAngle = 0
		savedPos = mcontroller.position()
		noclipVelocity = mcontroller.velocity()
	else
		tech.setParentState()
		mcontroller.setRotation(0)
		mcontroller.controlParameters(defaultParameters)
		mcontroller.setVelocity(noclipVelocity)
	end


end


function lerp(from, to, ratio)
	if type(from) == "table" or type(from) == "array" then --bam, lerping vectors and recursive function
		return {lerp(from[1],to[1],ratio),lerp(from[2],to[2],ratio)}
	else
		return from + (to - from) / ratio
	end
end
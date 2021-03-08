
local lastIdentity = currentIdentity
local identityList = root.assetJson("/fancyFerion/modules/identityController/identityList.json")

-- all copied from expanded anims. TODO: clean up and refactor

local breathHeadCurrentFrame = 1
local breathHeadLastFrame = breathHeadCurrentFrame
local breathHeadFrames = {
	{0,0},
	{0,0},
	{0,0},
	{0,-1/5},
	{0,-2/5},
	{0,-2/5},
	{0,-2/5},
	{0,-2/5},
	{0,-2/5},
	{0,-1/5}
}
local breathHeadOffset = breathHeadFrames[breathHeadCurrentFrame]
local breathHeadAnimationTime = 60 * 6 -- 6 seconds
local breathHeadAnimationRate = math.floor(breathHeadAnimationTime/#breathHeadFrames)
local breathHeadTimer = breathHeadAnimationRate

local breathArmCurrentFrame = 5
local breathArmLastFrame = breathArmCurrentFrame
local breathArmFrames = {
	{0,-4/5},
	{0,-3/5},
	{0,-2/5},
	{0,-1/5},
	{0,0},
	{0,0},
	{0,0},
	{0,-1/5},
	{0,-2/5},
	{0,-3/5},
}
local breathArmOffset = breathArmFrames[breathArmCurrentFrame]
local breathArmAnimationTime = 60 * 6 -- 6 seconds
local breathArmAnimationRate = math.floor(breathArmAnimationTime/#breathArmFrames)
local breathArmTimer = math.floor(breathArmAnimationRate / 2)

function breathingInit()
end

function breathingUpdate(args)
	if currentIdentity ~= lastIdentity then
		local newIdentity = identityList[currentIdentity]
		dll.setPersonality(newIdentity.personalityIdle,newIdentity.personalityArmIdle,newIdentity.personalityHeadOffset[1],newIdentity.personalityHeadOffset[2],newIdentity.personalityArmOffset[1],newIdentity.personalityArmOffset[2])
	end
	lastIdentity = currentIdentity

	if identityList[currentIdentity].breathing then
		

		breathHeadTimer = math.max(breathHeadTimer - 1,0)
		if breathHeadTimer == 0 then
			breathHeadTimer = breathHeadAnimationRate
			breathHeadCurrentFrame = breathHeadCurrentFrame + 1
			if breathHeadCurrentFrame > #breathHeadFrames then
				breathHeadCurrentFrame = 1
			end
		end

		breathArmTimer = math.max(breathArmTimer - 1,0)
		if breathArmTimer == 0 then
			breathArmTimer = breathArmAnimationRate
			breathArmCurrentFrame = breathArmCurrentFrame + 1
			if breathArmCurrentFrame > #breathArmFrames then
				breathArmCurrentFrame = 1
			end
		end

		if breathHeadCurrentFrame ~= breathHeadLastFrame or breathArmCurrentFrame ~= breathArmLastFrame then
			local endHeadPos = vec2.add(identityList[currentIdentity].personalityHeadOffset,breathHeadFrames[breathHeadCurrentFrame])
			local endArmPos = vec2.add(identityList[currentIdentity].personalityArmOffset,breathArmFrames[breathArmCurrentFrame])

			dll.setPersonality(identityList[currentIdentity].personalityIdle,identityList[currentIdentity].personalityArmIdle,endHeadPos[1],endHeadPos[2],endArmPos[1],endArmPos[2])
			breathHeadLastFrame = breathHeadCurrentFrame
			breathArmLastFrame = breathArmCurrentFrame
		end
	end
end

function breathingUninit()
end



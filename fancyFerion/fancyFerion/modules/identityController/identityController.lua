
local lastIdentity = currentIdentity


function identityControllerInit()
	setIdentity(currentIdentity)
end

function identityControllerUpdate(args)
	if currentIdentity ~= lastIdentity then
		setIdentity(currentIdentity)
	end
	lastIdentity = currentIdentity
end

function identityControllerUninit()
	setIdentity(1)
end

function setIdentity(newIdentityNum)
	local newIdentity = identityList[newIdentityNum]

	dll.setHairType(newIdentity.hairGroup,newIdentity.hairType)
	dll.setHairDirectives(newIdentity.hairDirectives)
	dll.setSpecies(newIdentity.species)
	dll.setBodyDirectives(newIdentity.bodyDirectives)
	dll.setEmoteDirectives(newIdentity.emoteDirectives)
	dll.setFacialHair(newIdentity.facialHairGroup,newIdentity.facialHairType,newIdentity.facialHairDirectives)
	dll.setFacialMask(newIdentity.facialMaskGroup,newIdentity.facialMaskType,newIdentity.facialMaskDirectives)
	dll.setGender(newIdentity.gender == "female")
	dll.setName(newIdentity.name)
	dll.setPersonality(newIdentity.personalityIdle,newIdentity.personalityArmIdle,newIdentity.personalityHeadOffset[1],newIdentity.personalityHeadOffset[2],newIdentity.personalityArmOffset[1],newIdentity.personalityArmOffset[2])

	status.setStatusProperty("fancyFerionClothes",newIdentity.clothes)
end

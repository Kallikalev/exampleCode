require "/scripts/vec2.lua"



function applyDamageRequest(damageRequest)
	if math.floor(damageRequest.damage) ~= 0 then
		if damageRequest.sourceEntityId ~= nil and damageRequest.sourceEntityId ~= entity.id() then
			if world.magnitude(world.distance(world.entityPosition(entity.id()),world.entityPosition(damageRequest.sourceEntityId))) <= 8 then
				--world.sendEntityMessage(damageRequest.sourceEntityId,"applyStatusEffect","melting",1)
			end
		end


	end
	return {}
end

function init()
	status.setResourcePercentage("health",1)

	status.setPrimaryDirectives()
end

function update()

	-- fill player stats
	status.setResourcePercentage("energy",1)
	status.setResourcePercentage("health",1)

end

function uninit()
end

function precRand(min,max)
	return math.random(min*10000,max*10000)/10000
end
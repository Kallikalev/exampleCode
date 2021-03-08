require "/scripts/vec2.lua"

function init()
    parentId = config.getParameter("parentId")
    blockImage = config.getParameter("blockImage")
    materialConfig = config.getParameter("materialConfig")
    despawning = false

    lastPos = mcontroller.position()
    endPos = mcontroller.position()
    idlePos = mcontroller.position()

    followArrived = false

    glowTimer = 0
    waveTimer = 0

    curRole = config.getParameter("curRole")
    roleParameters = config.getParameter("roleParameters")

    script.setUpdateDelta(1)
end

function update()
end

function calledUpdate()
    updateMovement()
    updateAnimation()
end

function updateMovement()
    lastPos = endPos
    if curRole == "idle" then
        local bobMag = 0.5

        if world.magnitude(world.distance(endPos,world.entityPosition(parentId))) >= 30 or math.random(1,600) == 1 or world.pointCollision(lastPos) then
            local randDist = 10
            local numLoops = 0
            repeat
                idlePos = vec2.add(world.entityPosition(parentId),{math.random() * 2 * randDist - randDist,math.random() * 2 * randDist - randDist})
                --sb.logInfo(sb.printJson(idlePos))
                numLoops = numLoops + 1
            until world.lineCollision(vec2.add(endPos,{0,-bobMag}),vec2.add(endPos,{0,bobMag})) == nil or numLoops == 200
            
        end
        endPos = lerp(lastPos,idlePos,18)
        mcontroller.setPosition(vec2.add(endPos,{0,math.sin(waveTimer/24) * bobMag}))
        waveTimer = waveTimer + 1
    end

    if curRole == "follow" then
        endPos = lerp(lastPos,roleParameters.targetPos,12)
        
        mcontroller.setPosition(vec2.add(endPos,{0,math.sin(waveTimer/24)/ 4}))
        waveTimer = waveTimer + 1
    end
    if curRole == "shield" then

        local shieldPos = {2,-2 + 1 * (roleParameters.shieldPlace)}
        shieldPos = vec2.add(shieldPos,{math.cos((roleParameters.shieldPlace / 4 - 0.5) * 1.3) * 3 - 2.4,0})
        shieldPos = vec2.mul(shieldPos,{roleParameters.followDirection,1})
        shieldPos = vec2.add(shieldPos,roleParameters.followPosition)
        if world.magnitude(world.distance(lastPos,shieldPos)) < 0.2 then
            followArrived = true
        end
        if followArrived then
            endPos = lerp(lastPos,shieldPos,2)
        else
            endPos = lerp(lastPos,shieldPos,12)
        end
        mcontroller.setPosition(endPos)
    end

    if curRole == "platform" then

        local platformPos = {-1  + roleParameters.platformPlace,-3}
        platformPos = vec2.add(platformPos,roleParameters.followPosition)
        if world.magnitude(world.distance(lastPos,platformPos)) < 0.6 then
            followArrived = true
        end
        if followArrived then
            endPos = lerp(lastPos,platformPos,1)
        else
            endPos = lerp(lastPos,platformPos,12)
        end
        mcontroller.setPosition(endPos)
    end

    mcontroller.setVelocity({0,0})
end

function updateAnimation()
    local glowPercent = math.min(1,math.max(0,(math.sin(glowTimer/9) + 1)/2 * 0.5 + 0.3))
    local color = "05eefa" .. string.format("%02x",math.floor(glowPercent * 255))
    local chains = {{
        startPosition = vec2.add(mcontroller.position(),{-0.5,0}),
        endPosition = vec2.add(mcontroller.position(),{0.5,0}),
        segmentImage = blockImage,
        segmentSize = 1,
        renderLayer = "foregroundEntity+9999",
        fullbright = false
    },
    {
        startPosition = vec2.add(mcontroller.position(),{-0.5,0}),
        endPosition = vec2.add(mcontroller.position(),{0.5,0}),
        segmentImage = blockImage .. "?border=1;" .. color .. ";" .. color,
        segmentSize = 1,
        renderLayer = "foregroundEntity+9998",
        fullbright = true
    }}
    monster.setAnimationParameter("chains", chains)
    glowTimer = glowTimer + 1
end

function uninit()
end

function shouldDie()
    return despawning
end

function despawn() -- called from item script
    despawning = true
    spawnDespawnParticles()
end

function spawnDespawnParticles()
    local actions = {}
    local imageBounds = root.nonEmptyRegion(blockImage)
    local vel = vec2.mul(vec2.sub(mcontroller.position(),lastPos),20)
    for x = 0, 7 do
        for y = 0, 7 do
            table.insert(actions,{
                action = "particle",
                ["repeat"] = false,
                time = 0,
                specification = {
                    type = "textured",
                    collidesForeground = true,
                    image = blockImage .. "?crop=" .. x .. ";" .. y .. ";" .. (x+1) .. ";" .. (y+1),
                    timeToLive = 3,
                    position = vec2.add(vec2.add({1/16,1/16},{-0.5,-0.5}),vec2.div({x,y},8)),
                    layer = "front",
                    initialVelocity = vec2.add({0,-5},vel),
                    finalVelocity = vec2.add({0.0, -35.0},{0,vel[2]}),
                    approach = {0,20},
                    variance = {
                        initialVelocity = {3.0, 3.0}
                    }
                }
            })
        end
    end

    world.spawnProjectile("boltguide",mcontroller.position(),entity.id(),{0,0},false,{
        timeToLive = 0.02,
        persistentAudio = "/assetmissing.wav",
        processing = "?multiply=FFFFFF00",
        damageType = "NoDamage",
        movementSettings = {
            collisionPoly = jarray(),
            collisionEnabled = false
        },
        periodicActions = actions
    })
end

function setRole(newRole)
    curRole = newRole
    if curRole == "idle" then
        idlePos = lastPos
    end
    if curRole == "shield" or curRole == "platform" then
        followArrived = false
    end
end

function updateRoleParameters(newParameters)
    roleParameters = newParameters
end

function lerp(from, to, ratio)
	if type(from) == "table" or type(from) == "array" then --bam, lerping vectors and recursive function
		return {lerp(from[1],to[1],ratio),lerp(from[2],to[2],ratio)}
	else
		return (from + ((to - from) / ratio))
	end
end
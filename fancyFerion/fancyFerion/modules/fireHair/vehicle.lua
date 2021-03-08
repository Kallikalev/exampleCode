function init()
    parentId = config.getParameter("parentId")
    counter = config.getParameter("counter")
    fireHairConfig = root.assetJson("/fancyFerion/modules/fireHair/config.json")
end

function update()
    mcontroller.setPosition(world.entityPosition(parentId))
    mcontroller.setVelocity({0,0})
    if not world.entityExists(parentId) then
        vehicle.destroy()
    end

    local timeMultiplier = 2
    local loopTime = #fireHairConfig.frames * fireHairConfig.frameSpeed * 60 * timeMultiplier
    local lowerBound = 0.75
    local sinMul1 = math.sin((counter % loopTime)/loopTime * math.pi * 2) * (1-lowerBound) / 2 + lowerBound + (1-lowerBound) / 2
    local sinMul2 = -math.sin((counter % loopTime)/loopTime * math.pi * 2) * (1-lowerBound) / 2 + lowerBound + (1-lowerBound) / 2

    local intensityMul = 0.5

    local color1 = root.assetJson("/fancyFerion/modules/fireHair/config.json").light1.color
    for i, v in ipairs(color1) do
        color1[i] = color1[i] * fireHairConfig.light1.intensity * sinMul1
    end
    local color2 = root.assetJson("/fancyFerion/modules/fireHair/config.json").light2.color
    for i, v in ipairs(color2) do
        color2[i] = color2[i] * fireHairConfig.light2.intensity * sinMul2
    end


    animator.setLightColor("outer",color1)
    animator.setLightColor("inner",color2)

    counter = counter + 1
end

function uninit()
end
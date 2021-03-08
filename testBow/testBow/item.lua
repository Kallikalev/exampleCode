require "/scripts/vec2.lua"

function init()
    chargeMode = false
    limbRotation = 0
    limbRotationGoal = 0
    limbRotationMax = math.rad(10) -- maximum pullback angle
    maxDrawDist = 20 -- number of blocks behind the hand that is considered "fully charged"
    drawSpeed = 0.06 -- in fraction per tick


    shoulderOffset = 0.25 -- vertical offset between hand and shoulder. A constant
    verticalOffset = 0.15 - 1/16 -- offset between hand and where arrow rests

    drawStartAngle = 0 -- the angle you begin your draw at
    drawAngleFraction = 1 -- the amount your draw angle should be modified by. Smaller means more precise aiming
    armAngle = 0
    facingDirection = 1

    armFrames = {
        {frame ="rotation",minAngle = 0, point = {-2/8,0}},
        {frame = "swim.2",minAngle = math.rad(2), point = {-0.625,0.2}},
        {frame = "swimIdle.1",minAngle = math.rad(5), point = {-1,0.2}}
    }
    armFrameNum = 1

    topLimbRotationPoint = {0,3/8}
    bottomLimbRotationPoint = {2/8,-2/8}

    topLimbOffset = {-1 - 1/16,1 + 4/8 + 1/16}
    bottomLimbOffset = {-1 - 2/8 - 1/16,-1 - 4/8 - 1/16}

    stringThickness = 0.5
    stringColor = "ff0000"

    projectileMaxSpeed = 80

    previewMoveRate = 0.001 -- seconds offset per tick

    timer = 0
end

function update(dt, fireMode, shiftHeld)

    if fireMode == "primary" then
        if not chargeMode then
            drawStartAngle = armAngle
        end
        chargeMode = true
    else
        if chargeMode then
            if limbRotation > 0.1 * limbRotationMax then
                fire()
            end
        end
        chargeMode = false
    end

    if chargeMode then
        charge()
    else
        idle()
    end
    
    activeItem.setFrontArmFrame(armFrames[armFrameNum].frame)

    doTransforms()
    doAim()

    timer = timer + 1
end

function uninit()
end

function idle()
    limbRotation = 0
    armFrameNum = 1

    armAngle, facingDirection = activeItem.aimAngleAndDirection(verticalOffset - shoulderOffset,vec2.add(vec2.sub(mcontroller.position(),activeItem.ownerAimPosition()),mcontroller.position()))

end

function charge()
    drawMouseAngle, facingDirection = activeItem.aimAngleAndDirection(verticalOffset - shoulderOffset,vec2.add(vec2.sub(mcontroller.position(),activeItem.ownerAimPosition()),mcontroller.position()))
    local handWorldPos = vec2.add(mcontroller.position(),activeItem.handPosition())
    local drawPos = vec2.add(vec2.mul(vec2.rotate({0,verticalOffset},armAngle),{facingDirection,1}),handWorldPos)
    local drawPercentage = math.min(world.magnitude(activeItem.ownerAimPosition(),handWorldPos)/maxDrawDist,1)
    limbRotationGoal = drawPercentage * limbRotationMax

    armAngle = (drawMouseAngle - drawStartAngle) * drawAngleFraction + drawStartAngle

    limbRotation = math.min(limbRotationGoal,limbRotation + limbRotationMax * drawSpeed)

    armFrameNum = 1

    for i, v in ipairs(armFrames) do
        if limbRotation > v.minAngle then
            armFrameNum = i
        end
    end

    world.debugPoint(vec2.add(mcontroller.position(),vec2.add(activeItem.handPosition(),armFrames[armFrameNum].point)),"red")

    local arrowPos = vec2.add(vec2.mul(vec2.rotate({0,verticalOffset},armAngle),{facingDirection,1}),activeItem.handPosition())
    local gravity = world.gravity(activeItem.ownerAimPosition())
    local arrowVel = vec2.mul(vec2.rotate({limbRotation/limbRotationMax * projectileMaxSpeed,0},armAngle),{facingDirection,1}) -- in blocks per second

    local stepTime = 0.1

    local stepOffset = (timer * previewMoveRate) % stepTime

    for t = stepTime, 4, stepTime do
        local x = (t+stepOffset) * arrowVel[1] + arrowPos[1]
        local y = (t+stepOffset) * arrowVel[2] - 0.25 * gravity * (t+stepOffset) ^ 2 + arrowPos[2]
        local x2 = (t-stepTime+stepOffset) * arrowVel[1] + arrowPos[1]
        local y2 = (t-stepTime+stepOffset) * arrowVel[2] - 0.25 * gravity * (t-stepTime+stepOffset) ^ 2 + arrowPos[2]
        if world.lineCollision(vec2.add({x,y},mcontroller.position()),vec2.add(mcontroller.position(),{x2,y2})) then
            break
        end
        world.sendEntityMessage(activeItem.ownerEntityId(),"testBowAddDrawable",{
            image = "/celestial/system/gas_giant/gas_giant_base.png?setcolor=eeffff",
            position = {x,y},
            fullbright = true,
            scale = 0.007
        },"Player+1")
    end

end

function fire()
    local handWorldPos = vec2.add(mcontroller.position(),activeItem.handPosition())
    local p1 = vec2.add(vec2.mul(vec2.rotate({0,verticalOffset},armAngle),{facingDirection,1}),handWorldPos)

    world.spawnProjectile("chargedlightarrow",p1,activeItem.ownerEntityId(),vec2.mul(vec2.rotate({1,0},armAngle),{facingDirection,1}),nil,{
        processing = "?crop;0;0;1;1?setcolor=fff?replace;fff0=fff?border=1;fff;000?scale=1.15;1.12?crop;1;1;3;3?replace;fbfbfb=0000;eaeaea=18000000;e4e4e4=00000900;6a6a6a=18000900?scale=23.5;8.5?crop=0;0;24;9?replace;00000300=110;00000400=010;00000500=010;01000300=010;01000400=210;01000500=010;02000300=110;02000400=210;02000500=010;03000300=010;03000400=fff;03000500=010;04000400=fff;05000400=fff;06000400=fff;07000400=fff;08000400=fff;09000400=fff;0a000400=fff;0b000400=fff;0c000400=fff;0d000400=fff;0e000400=fff;0f000400=210;10000400=210;11000300=e7eff7;11000400=210;11000500=e7eff7;12000300=010;12000400=fff;12000500=010;13000300=010;13000400=fff;13000500=010;14000300=110;14000400=fff;14000500=110;15000400=110?replace;010=f7a619;110=ea850e;210=f5ea2d",
        speed = limbRotation/limbRotationMax * projectileMaxSpeed,
        power = 10
    })
end

function doTransforms()
    local groups = {"bottomString","topString","limbBottom","limbTop","arrow","base"}
    for i, v in ipairs(groups) do
        animator.resetTransformationGroup(v)
    end

    local topStringTipPos = vec2.add(vec2.add(vec2.rotate(topLimbOffset,limbRotation),topLimbRotationPoint),{0.8,0})
    local bottomStringTipPos = vec2.add(vec2.add(vec2.rotate(bottomLimbOffset,-limbRotation),bottomLimbRotationPoint),{0.8,0})

    local handFramePoint = armFrames[armFrameNum].point

    -- good a place as any
    animator.setGlobalTag("stringDirectives","?setcolor=" .. stringColor)

    animator.scaleTransformationGroup("topString",{stringThickness,world.magnitude(topStringTipPos,handFramePoint)*8}) -- convert from blocks to pixels
    animator.scaleTransformationGroup("bottomString",{stringThickness,world.magnitude(bottomStringTipPos,handFramePoint)*8})

    animator.rotateTransformationGroup("topString",-math.atan(table.unpack(vec2.sub(topStringTipPos,handFramePoint))))
    animator.rotateTransformationGroup("bottomString",-math.atan(table.unpack(vec2.sub(bottomStringTipPos,handFramePoint))))

    animator.translateTransformationGroup("topString",vec2.div(vec2.add(topStringTipPos,handFramePoint),2))
    animator.translateTransformationGroup("bottomString",vec2.div(vec2.add(bottomStringTipPos,handFramePoint),2))

    animator.translateTransformationGroup("arrow",{armFrames[armFrameNum].point[1],0})

    animator.scaleTransformationGroup("base",0.8)
    animator.translateTransformationGroup("base",{0.8,-0.25})

    animator.rotateTransformationGroup("limbTop",limbRotation,topLimbRotationPoint)
    animator.rotateTransformationGroup("limbBottom",-limbRotation,bottomLimbRotationPoint)
end

function doAim()
    activeItem.setArmAngle(armAngle)
    activeItem.setFacingDirection(facingDirection)
end
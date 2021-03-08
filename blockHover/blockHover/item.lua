require "/scripts/vec2.lua"

function init()
    leftDown = false
    rightDown = false
    leftStartPos = activeItem.ownerAimPosition()

    shieldActive = false
    shieldFollowDirection = 1

    platformActive = false
    platformPos = mcontroller.position()
    platformVelocity = {0,0}

    blocks = {}

    activeItem.setTwoHandedGrip(false)
end

function update(dt,fireMode,shiftHeld,controls)
    getClicks(fireMode,shiftHeld,controls)
    updateAim()

    if shieldActive then
        local numShieldBlocks = 0
        if mcontroller.velocity()[1] > 0 and mcontroller.facingDirection() == 1 then
            shieldFollowDirection = 1
        elseif mcontroller.velocity()[1] < 0 and mcontroller.facingDirection() == -1 then
            shieldFollowDirection = -1
        end
        for i, v in ipairs(blocks) do
            if v.role == "shield" then
                blocks[i].roleParameters.followDirection = shieldFollowDirection
                blocks[i].roleParameters.followPosition = mcontroller.position()
                numShieldBlocks = numShieldBlocks + 1
            end
        end
        if numShieldBlocks == 0 then
            shieldActive = false
        end
    end

    if platformActive then
        local moveSpeed = 0.5
        local frictionMul = 0.98
        local newPos = platformPos

		if controls.up then
			platformVelocity[2] = platformVelocity[2] + moveSpeed
		end
		if controls.down then
			platformVelocity[2] = platformVelocity[2] - moveSpeed
		end
		if controls.left then
			platformVelocity[1] = platformVelocity[1] - moveSpeed
		end
		if controls.right then
			platformVelocity[1] = platformVelocity[1] + moveSpeed
		end

        newPos = vec2.add(newPos,vec2.div(platformVelocity,60))
        platformVelocity = vec2.mul(platformVelocity,frictionMul)

        platformPos = newPos

        mcontroller.setPosition(platformPos)
        mcontroller.setVelocity({0,0})

        local numPlatformBlocks = 0

        for i, v in ipairs(blocks) do
            if v.role == "platform" then
                blocks[i].roleParameters.followPosition = platformPos
                numPlatformBlocks = numPlatformBlocks + 1
            end
        end
        if numPlatformBlocks == 0 then
            platformActive = false
        end
    end

    for i, v in ipairs(blocks) do
        if world.entityExists(v.id) then
            if v.role == "follow" then
                blocks[i].roleParameters = {
                    targetPos = activeItem.ownerAimPosition()
                }
            end
            world.callScriptedEntity(v.id,"updateRoleParameters",blocks[i].roleParameters)
            world.callScriptedEntity(v.id,"calledUpdate")
        end
    end
end

function getClicks(fireMode,shiftHeld,controls)
    if fireMode == "primary" then
        if not leftDown then
            leftClick(fireMode,shiftHeld,controls)
        end
        leftDown = true
    else
        leftDown = false
    end

    if fireMode == "alt" then
        if not rightDown then
            rightClick(fireMode,shiftHeld,controls)
        end
        rightDown = true
    else
        rightDown = false
    end
end

function leftClick(fireMode,shiftHeld,controls)
    if not (controls.up or controls.down or controls.left or controls.right) then -- swap between follow and idle
        for _, id in ipairs(world.monsterQuery(activeItem.ownerAimPosition(),5,{order = "nearest", boundMode = "position"})) do
            for i, block in ipairs(blocks) do
                if block.id == id then
                    if world.entityExists(id) then
                        if block.role == "idle" then
                            world.callScriptedEntity(id,"setRole","follow")
                            blocks[i].role = "follow"
                        elseif block.role == "follow" then
                            world.callScriptedEntity(id,"setRole","idle")
                            blocks[i].role = "idle"
                        end
                    end
                end
            end
        end
    elseif controls.up then
        if shieldActive then
            for i, v in ipairs(blocks) do
                if v.role == "shield" then
                    blocks[i].role = "idle"
                    world.callScriptedEntity(blocks[i].id,"setRole","idle")
                end
            end
            shieldActive = false
        else
            local shieldIndexes = {}
            for i, v in ipairs(blocks) do
                if v.role == "idle" then
                    table.insert(shieldIndexes,i)
                end

            end
            if #shieldIndexes >= 5 then
                local shuffled = {}
                for i, v in ipairs(shieldIndexes) do
                    local pos = math.random(1, #shuffled+1)
                    table.insert(shuffled, pos, v)
                end
                shieldIndexes = shuffled

                shieldActive = true
                shieldFollowDirection = mcontroller.facingDirection()
                for i, v in ipairs(shieldIndexes) do
                    blocks[v].role = "shield"
                    world.callScriptedEntity(blocks[v].id,"setRole","shield")
                    blocks[v].roleParameters = {
                        shieldPlace = i - 1, -- position in the shield, top to bottom
                        followPosition = mcontroller.position(),
                        followDirection = mcontroller.facingDirection()
                    }
                    if i == 5 then
                        break
                    end
                end
            end
        end


    elseif controls.down then
        if platformActive then
            for i, v in ipairs(blocks) do
                if v.role == "platform" then
                    blocks[i].role = "idle"
                    world.callScriptedEntity(blocks[i].id,"setRole","idle")
                end
            end
            platformActive = false
        else
            local platformIndexes = {}
            for i, v in ipairs(blocks) do
                if v.role == "idle" then
                    table.insert(platformIndexes,i)
                end

            end
            if #platformIndexes >= 3 then
                local shuffled = {}
                for i, v in ipairs(platformIndexes) do
                    local pos = math.random(1, #shuffled+1)
                    table.insert(shuffled, pos, v)
                end
                platformIndexes = shuffled

                platformActive = true
                platformPos = mcontroller.position()
                platformVelocity = {0,0}

                for i, v in ipairs(platformIndexes) do
                    blocks[v].role = "platform"
                    world.callScriptedEntity(blocks[v].id,"setRole","platform")
                    blocks[v].roleParameters = {
                        platformPlace = i - 1, -- position in the shield, top to bottom
                        followPosition = mcontroller.position()
                    }
                    if i == 3 then
                        break
                    end
                end
            end
        end
    end
end

function rightClick(fireMode,shiftHeld,controls)
    local blockFound = false
    for _, id in ipairs(world.monsterQuery(activeItem.ownerAimPosition(),3,{order = "nearest", boundMode = "position"})) do
        for i, block in ipairs(blocks) do
            if block.id == id then
                blockFound = true
                if world.entityExists(id) then
                    world.callScriptedEntity(id,"despawn")
                end
                table.remove(blocks,i)
                break
            end
        end
    end
    if not blockFound then
        -- copied from fire manipulator
        local buildMaterial = nil
        local scannedMaterial = world.material(activeItem.ownerAimPosition(),"foreground")
        local materialHueshift = 0
        if scannedMaterial then
            buildMaterial = scannedMaterial
            buildColor = world.materialColor(activeItem.ownerAimPosition(),"foreground")
            materialHueshift = world.materialHueShift(activeItem.ownerAimPosition(),"foreground")
        else
            scannedMaterial = world.material(activeItem.ownerAimPosition(),"background")

            if scannedMaterial then
                buildMaterial = scannedMaterial
                buildColor = world.materialColor(activeItem.ownerAimPosition(),"background")
                materialHueshift = world.materialHueShift(activeItem.ownerAimPosition(),"background")
            end
        end
        if buildMaterial then
            local materialPath = root.materialConfig(buildMaterial).path
            local materialConfig = root.assetJson(materialPath)
            local renderTemplate = root.assetJson(materialConfig.renderTemplate) or "/tiles/classicmaterialtemplate.config" -- default template

            local materialImage = materialConfig.renderParameters.texture
            -- image processing junk to make an absolute or relative file path
            if (materialImage:sub(1,1) ~= "/") then -- if it starts with a slash then it's an absolute path and we're done
                local lastSlash = materialPath:match'^.*()/' -- stackoverflow credit to https://stackoverflow.com/users/1847592/egor-skriptunoff for the fast finding of last slash
                materialImage = materialPath:sub(1,lastSlash) .. materialImage -- make it the same as the .material file's path with the image added
            end

            local numVariants = materialConfig.renderParameters.variants
            local muliColored = materialConfig.renderParameters.multiColored

            if (materialConfig.renderTemplate == "/tiles/classicmaterialtemplate.config") then -- only testing basic render template for now
                local pieceConfig = renderTemplate.pieces.base
                local colorStride = pieceConfig.colorStride
                local imageSize = root.imageSize(materialImage)
                local cropSize = pieceConfig.textureSize
                local cropPos = pieceConfig.texturePosition
                cropPos = vec2.add(cropPos,vec2.mul(colorStride,buildColor)) -- shift down based on color
                local blockImage = materialImage .. "?crop=" .. tostring(cropPos[1]) .. ";" .. tostring(imageSize[2] - (cropPos[2] + cropSize[2])) .. ";" .. tostring(cropPos[1] + cropSize[1]) .. ";" .. tostring(imageSize[2] - (cropPos[2]))
                

                local newRole = nil
                local newRoleParams = nil
                if shiftHeld then
                    newRole = "follow"
                    newRoleParams = {
                        targetPos = activeItem.ownerAimPosition()
                    }
                else
                    newRole = "idle"
                    newRoleParams = {}
                end

                local monsterId = world.spawnMonster("mechshielddrone", activeItem.ownerAimPosition(), { -- spawn controller with standard parameters
                    scripts = {"/blockHover/monster.lua"},
                    animationScripts = {"/items/active/effects/chain.lua"},
                    statusSettings = {
                        primaryScriptSources = {
                            "/blockHover/monsterStatus.lua"
                        }
                    },
                    movementSettings = {
                        collisionEnabled = false,
                        collisionPoly = jarray()
                    },
                    scale = 1,
                    animationCustom = {
                        animatedParts = {
                            stateTypes = {
                                droneState = {
                                    default = "active",
                                    states = {
                                        active = {
                                            frames = 1,
                                            cycle = 1,
                                            mode = "loop",
                                            properties = {
                                                persistentSound = "/assetmissing.wav"
                                            }
                                        }
                                    }
                                }
                            },
                            parts = {
                                body = {
                                    partStates = {
                                        droneState = {
                                            deploy = {
                                                properties = {
                                                    image = "/assetmissing.png"
                                                }
                                            },								
                                            active = {
                                                properties = {
                                                    image = "/assetmissing.png"
                                                }
                                            }
                                        }
                                    }
                                },
                                bodyFullbright = {
                                    partStates = {
                                        droneState = {
                                            deploy = {
                                                properties = {
                                                    image = ""
                                                }
                                            },								
                                            active = {
                                                properties = {
                                                    image = ""
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        },
                        sounds = {},
                        lights = {}
                    },
                    parentId = activeItem.ownerEntityId(),
                    blockImage = blockImage,
                    materialConfig = materialConfig,
                    curRole = newRole,
                    roleParameters = newRoleParams
                })

                table.insert(blocks,{
                    id = monsterId,
                    role = newRole,
                    roleParameters = newRoleParams
                })
            end
        end
    end
end


function uninit()
    for i, v in ipairs(blocks) do
        if world.entityExists(v.id) then
            world.callScriptedEntity(v.id,"despawn")
        end
    end
end

-- my boilerplate aimable item code
function updateAim()
	local aimPos = activeItem.ownerAimPosition()
	self.angle, self.direction = activeItem.aimAngleAndDirection(0,aimPos)
	activeItem.setArmAngle(self.angle)
	activeItem.setFacingDirection(self.direction)
end
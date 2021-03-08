local counter = 0
local currentFrame = 1
local fireHairActive = status.statusProperty("fireHairActive",false)
local vehicleId = nil

function fireHairInit()
    fireHairConfig = root.assetJson("/fancyFerion/modules/fireHair/config.json")

    Bind.create("specialTwo=true up=false down=false left=true right=false",toggleFireHairActive,false)
end

function fireHairUpdate(args)

    -- TODO: make be it's own file
    r,g,b = color.hex2rgb(color.hueshiftHex("ff0000",counter/240))
    dll.setColor(r,g,b,255)

    if fireHairActive then
        local hairDirectives = fireHairConfig.frames[currentFrame]

        dll.setHairDirectives(hairDirectives)

        if counter % math.floor(fireHairConfig.frameSpeed*60) == 0 then
            currentFrame = (currentFrame % #fireHairConfig.frames) + 1
        end

        if vehicleId == nil or not world.entityExists(vehicleId) then
            spawnVehicle()
        end
    end
    counter = counter + 1
end

function toggleFireHairActive()
    fireHairActive = not fireHairActive
    status.setStatusProperty("fireHairActive",fireHairActive)
    if fireHairActive then
        currentIdentity = 2
        currentChatPreset = 2
    else
        despawnVehicle()
        currentIdentity = 1
        currentChatPreset = 1
    end
end

function fireHairUninit()
    dll.setHairDirectives("")
    despawnVehicle()
    currentIdentity = 1
    status.setStatusProperty("fireHairActive",false)
end

function spawnVehicle()
    vehicleId = world.spawnVehicle("rustyrailplatform",mcontroller.position(),{
        physicsCollisions = {},
        script = "/fancyFerion/modules/fireHair/vehicle.lua",
        parentId = entity.id(),
        counter = counter,
        clientEntityMode = "ClientMasterAllowed",
        movementSettings = {
            mass = 0,
            gravityEnabled = false,
            collisionEnabled = false,
            collisionPoly = jarray(),
            categoryBlacklist = jarray()
        },
        animationCustom = {
            animatedParts = {
                parts = {
                    platform = {
                        partStates = {
                            rail = {
                                on = {
                                    properties = {
                                        image = "/assetmissing.png",
                                        offset = {0,0}
                                    }
                                },
                                off = {
                                    properties = {
                                        image = "/assetmissing.png",
                                        offset = {0,0}
                                    }
                                }
                            }
                        }
                    }
                }
            },
            lights = {
                outer = {
                    color = {255 * 0.75,255 * 0.5 * 0.75,0},
                    position = {0,0},
                    active = true
                },
                inner = {
                    color = {255*0.5,255*0.5,0},
                    position = {0,0},
                    active = true
                }
            }
        }
    })
end

function despawnVehicle()
    if vehicleId and world.entityExists(vehicleId) then
        world.callScriptedEntity(vehicleId,"vehicle.destroy")
    end
end
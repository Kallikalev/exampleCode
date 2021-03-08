local ini = init or function() end
local upd = update or function() end
local unini = uninit or function() end

function init()
    ini()
    
    vehicleId = nil


end

function update(...)
    upd(...)
    if vehicleId == nil or not world.entityExists(vehicleId) then
        vehicleId = world.spawnVehicle("rustyrailplatform",world.entityPosition(player.id()),{
            physicsCollisions = {
                platform = {
                collision = {{-0.75,-2},{-0.35,-2.5},{0.35,-2.5},{0.75,-2},{0.75,0.65},{0.35,1.22},{-0.35,1.22},{-0.75,0.65}},
                    collisionKind = "platform",
                    attachToPart = "platform"
                }
            },
            script = "/headPlatform/vehicle.lua",
            parentId = player.id(),
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
                }
            }
        })
    end
end

function uninit()
    unini()
    if vehicleId and world.entityExists(vehicleId) then
        world.callScriptedEntity(vehicleId,"vehicle.destroy")
    end
end
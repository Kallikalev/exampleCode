function playerId()
    if player then
        return player.id()
    elseif entity then
        return entity.id()
    elseif activeItem then
        return activeItem.ownerEntityId()
    end
end

dll = package.loadlib("workingLogger.dll","dll_init")()


function loadPointers()
    world.sendEntityMessage(playerId(),"loadPointers")
    world.entityQuery(world.entityPosition(playerId()),10)
    root.imageSize("/assetmissing.png")
end
local inferionCompressedPixelmap = "HB0AAAAAbikA/69OAP9VVVX/hTYA/+qZMf+oVQD/ODg4/xUVFf/506n/s3xd/0crE/9XHQD/pHhE/3VMI/+WSQT/wW4A/9OlfP89LCv/1NLM/4E/Ev9EVVT/mEoD/2wqAv9mfWP/NEQA/8C4uP9wNxP/XHNa/wGNAQyCDwyDAQyCDwyNAQyCDgyDAQyCDgyNAYECgQ8MgwEMgQ8MjgECBgIODIMCDIEODI4BAgMGAgyDAwyBDgyPAQIGAgQJggMJgQQIjwECBgIECYEDCYIECI8BAgMGAgmBAwmBBAiRAQIGAgSBCYIECJEBAgYCgQSBCIEECI0BC4IBAgYChAQIjQELCgsBCwIDBgKDBAiBC4sBC4EKCwoLAYECAwmBCAOBCguLAQuCCgsBAwIGCQQIBhIKC4sBA4EGAoEBAwIGCYEIBgoLjAEDgQYCgQEDAgYJBAgGA40BCIEECAkDAgYJgQgGA48BCIEECAkCBgkECAaRAQgEggIDCYEIA5ABggIGgQMJgQQDCYICjQEDggYDCYIICYIGA44BggMNCxKCCguBA5EBDQsSBYMKCw2QAQ0cEgUHFBmBChYFkAENBRUFBxsdEAoaBY8BDYIFEAeBExcFExANjwENBYIHEAUHgQUHGJABDQUHgRGDBxEFjwENBRARhgcFkAENgQWFBwWSAQ2DBQeBBZQBgQ0FBxCYAQ0HBZgBDQU="


local afkActive = false
local afkPos = nil

local blinkFrequency = 120 -- ticks between blinks
local blinkDuration = 100

function afkInit()
	Bind.create("specialOne=true up=false down=true left=false right=false",toggleAfk,false)
end

function afkUpdate(args)
	if afkActive then
		mcontroller.setPosition(afkPos)
		mcontroller.setVelocity({0,0})
		tech.setParentState("stand")
		tech.setToolUsageSuppressed(true)

		if afkTimer % blinkFrequency == 0 then
			spawnBlinks()
		end

		afkTimer = afkTimer + 1
	end
end

function afkUninit()
	local s = standardPersonality
	tech.setParentState()
	tech.setParentHidden(false)
	dll.setName("Inferion")
end

function toggleAfk()
	afkActive = not afkActive
	if afkActive then
		afkPos = mcontroller.position()
		afkTimer = 0
		tech.setParentHidden(true)
		dll.setName("Inferion\n^gray;[^white;AFK^gray;]")
	else
		tech.setParentDirectives("")
		tech.setParentState()
		tech.setParentOffset({0,0})
		tech.setToolUsageSuppressed(false)
		tech.setParentHidden(false)
		dll.setName("Inferion")
	end
end

function spawnBlinks()

    local pixelmap = decompressPixelmap(inferionCompressedPixelmap)

    local particleActions = {}

    for i, v in ipairs(pixelmap) do
        pixelmap[i].basePosition[1] = v.basePosition[1] + 1
    end

    if mcontroller.facingDirection() == -1 then
        for i, v in ipairs(pixelmap) do
            v.basePosition[1] = 44 - v.basePosition[1]
        end
	end
	
    for i, v in ipairs(pixelmap) do
		local r, g, b = color.hex2rgb(v.baseColor)
		
		local h, s, l = color.rgb2hsl(r,g,b)

		s = s * 0.2

		l = (1-l)*0.6+l

		r, g, b = color.hsl2rgb(h,s,l)

		local pixelPos = vec2.div(vec2.add(v.basePosition,{-22,-19.5}),8)

        local newAction = {
            action = "particle",
            time = math.random() * blinkFrequency / 60,
            ["repeat"] = false,
            specification = {
                type = "ember",
                color = {r,g,b,220},
				timeToLive = blinkDuration / 60 /4*3,
				destructionTime = blinkDuration /60 / 4,
				destructionAction = "shrink",
                layer = "middle",
                collidesForeground = false,
                position = pixelPos
            }
        }
        table.insert(particleActions,newAction)

	end

    world.spawnProjectile("boltguide", afkPos, entity.id(), {0, 0}, false, {
        damageType = "NoDamage",
        processing = "?setcolor=000000?replace;000000=ffffff00",
        movementSettings = {
            collisionPoly = jarray()
        },
        timeToLive = 3,
        actionOnReap = jarray(),
        periodicActions = particleActions
	})
end
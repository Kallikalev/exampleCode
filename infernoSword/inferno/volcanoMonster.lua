require "/scripts/vec2.lua"
function init()
	message.setHandler("erupt",function(_, clientSender)
		if clientSender then
			erupting = true
			eruptStartTime = timer
			animator.setSoundVolume("erupt",2)
			animator.setSoundPitch("erupt",0.5)
			animator.playSound("erupt")
		end
	end)

	message.setHandler("despawn",function(_, clientSender)
		if clientSender then
			despawning = true
			timer = delayTime + riseTime
			erupting = false
			animator.setSoundVolume("rumble",0,riseTime/60)
		end
	end)
	despawning = false

	spawnPos = mcontroller.position()
	riseTime = config.getParameter("riseTime")
	timer = 0
	delayTime = config.getParameter("delayTime")
	riseAmount = config.getParameter("riseAmount")

	shakeAmount = 0.2

	eruptTime = 60 -- number of ticks it takes to start up
	erupting = false

	animator.setSoundVolume("rumble",0)
	animator.setSoundVolume("rumble",1,(delayTime+riseTime)/60)
	animator.setSoundPitch("rumble",0.1)
	animator.playSound("rumble",-1)
	script.setUpdateDelta(1)
end

function update()
	world.debugText(script.updateDt(),mcontroller.position(),"green")

	if despawning then
		timer = timer - 1
	else
		timer = timer + 1
	end
	if timer < delayTime then
		mcontroller.setPosition(spawnPos)
	end
	if timer >= delayTime and timer < delayTime + riseTime then
		local percent = (timer - delayTime)/riseTime
		local shake = math.random() * shakeAmount * 2 - shakeAmount
		mcontroller.setPosition(vec2.add(spawnPos,{shake,riseAmount * percent}))
	end
	if timer >= delayTime + riseTime then
		local shake = (math.random() * shakeAmount * 2 - shakeAmount) * 0.2
		mcontroller.setPosition(vec2.add(spawnPos,{shake,riseAmount}))
	end
	mcontroller.setVelocity({0,0})

	local chains = {}
	if erupting then
		
		local startPos = vec2.add(mcontroller.position(),{0,0})
		local endPos = vec2.add(startPos,{0,40})
		local collisionPos = world.lineCollision(startPos,endPos) or endPos

		local beamYScale = math.min((timer - eruptStartTime)/eruptTime,1)
		local beamDirectives = "?replace;e19cf4=da5302;f9d9ff=fd8f4d;af59d2=bb2a02" .. "?scalenearest=1;" .. tostring(beamYScale)
		table.insert(chains,{
			segmentImage = "/items/active/weapons/ranged/abilities/erchiusbeam/beam.png:4" .. beamDirectives,
			endSegmentImage = "/items/active/weapons/ranged/abilities/erchiusbeam/beamend.png:4" .. beamDirectives,
			segmentSize = 0.5,
			overdrawLength = 0.2,
			taper = 0,
			waveform = {
				frequency = 3.0,
				amplitude = 0.2,
				movement = 30.0
			},
			fullbright = true,
			endPosition = collisionPos,
			startPosition = startPos,
			renderLayer = "Monster-1"
		})
		


		if (timer - eruptStartTime) % 120 == 5 then
			local actions = {}
			local particleStartPos = vec2.add(mcontroller.position(),{0,1.3})

			table.insert(actions,{ -- embers
				["repeat"] = true,
				time = 0.2,
				action = "particle",
				specification = 	{
					type = "animated",
					animation = getFireAnimation("ff8000","ffffff"),
					approach = {3, 40},
					timeToLive = 2,
					light = {255,156,0,156},
					fullbright = true,
					initialVelocity = {0,30},
					finalVelocity = {0,-5},
					angularVelocity = 30,
					variance = {
                		timeToLive = 0.15,
                		position = {0.5, 0.5},
                		initialVelocity = {8, 6},
						finalVelocity = {3,0},
                		rotation = 180
					}
				}
			})

			table.insert(actions,{ -- smoke
				["repeat"] = true,
				time = 0.1,
				action = "particle",
				specification = 	{
					type = "animated",
					animation = "/animations/smoke/smoke.animation",
					size = 0.5,
					approach = {3, 20},
					timeToLive = 3,
					fullbright = true,
					initialVelocity = {0,20},
					finalVelocity = {0,-5},
					variance = {
                		timeToLive = 0.25,
                		position = {0.5, 0.5},
                		initialVelocity = {6, 8},
						finalVelocity = {3,0},
                		rotation = 180
					}
				}
			})


			table.insert(actions,{ --unmelted magma
				["repeat"] = true,
				time = 0.03,
				action = "particle",
				specification = 	{
					type = "textured",
					image = "/animations/ember1/ember1.png?crop=1;2;2;3?replace;fd8f4d=575d5e",
					size = 1,
					timeToLive = 2,
					fullbright = true,
					velocity = {0,20},
					variance = {
                		position = {0.5, 0.5},
                		rotation = 180
					}
				}			
			})

			world.spawnProjectile("boltguide",particleStartPos,entity.id(),{0,0},false,{
				timeToLive = 2, -- convert to seconds
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
	end

	monster.setAnimationParameter("chains", chains)
end

function uninit()
end

function shouldDie()
	return despawning and timer < delayTime
end

function getFireAnimation(color1,color2)
	return "/animations/ember1/ember1.animation?crop=1;2;2;3?replace;fd8f4d=" .. color1 .. ";da5302=" .. color2 .. ";fdd14d=" .. color2
end
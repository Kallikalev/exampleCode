require "/scripts/vec2.lua"
require "/inferno/Bezier.lua"
require "/scripts/poly.lua"
require "/inferno/Color.lua"
require "/scripts/rect.lua"

lerpSpeed = 8

armAngle = -math.pi/2
forcedArmAngle = nil
forcedFacingDirection = nil
twoHanded = false

currentState = "idle" -- all state transition

primaryDown = false
altDown = false

function init()
	world.sendEntityMessage(activeItem.ownerEntityId(),"infernoSheathed",false)

	states[currentState].init(states[currentState])

	setupGroups()

	-- delete this me
	swooshes = {}	local m = mcontroller.position()
	local p = poly.translate({{5,5},{20,5},{5,20},{20,20}},mcontroller.position())
	table.insert(swooshes,getCurve(p))
end

function update(dt,fireMode,shiftHeld)
	updateCombos(fireMode,shiftHeld)
	controlStates(fireMode,shiftHeld)

	updateGroups()
	updateAim()

	-- delete this me
	for _, c in ipairs(swooshes) do
		for i, v in ipairs(c) do
			if i == #c then
				break
			end
			world.debugLine(v,c[i + 1],"green")
		end
	end
end

function uninit()
	states[currentState].uninit(states[currentState])
	world.sendEntityMessage(activeItem.ownerEntityId(),"infernoSheathed",true)
end

function setupGroups()
	for i, v in pairs(groups) do
		groups[i].currentTranslation = v.endTranslation
		groups[i].currentScale = v.endScale
		groups[i].currentRotation = v.endRotation
		groups[i].currentRotationPoint = v.endRotationPoint
	end
end

function updateCombos(fireMode,shiftHeld) -- each state will have a `canCombo` parameter and next states for left and right click
	if fireMode == "primary" then
	-- feels more responsive if you do it on click, not release (and you can do click and holds)
		if not primaryDown and states[currentState].canCombo == true and states[currentState].nextStatePrimary then
			changeState(states[currentState].nextStatePrimary)
		end
		primaryDown = true
	else
		primaryDown = false
	end
	if fireMode == "alt" then
		if not altDown and states[currentState].canCombo == true and states[currentState].nextStateAlt then
			changeState(states[currentState].nextStateAlt)
		end
		altDown = true
	else
		altDown = false
	end
end

function changeState(newState)
	states[currentState].uninit(states[currentState])
	currentState = newState
	states[newState].init(states[newState])
end

function controlStates(fireMode,shiftHeld)
	states[currentState].update(states[currentState],fireMode,shiftHeld)
end

function updateAim() -- updates aim
	local aimPos = activeItem.ownerAimPosition()
	goalAngle, facingDirection = activeItem.aimAngleAndDirection(0,aimPos)

	if forcedArmAngle then
		goalAngle = forcedArmAngle	
	end

	armAngle = lerp(armAngle,goalAngle,lerpSpeed)
	activeItem.setArmAngle(armAngle)

	if forcedFacingDirection then
		facingDirection = forcedFacingDirection
	end

	activeItem.setFacingDirection(facingDirection)
	activeItem.setTwoHandedGrip(twoHanded)
end

function updateGroups() -- transform all groups, with accounting for rotation and scale centers
	for i, v in pairs(groups) do
		v.currentScale = lerp(v.currentScale,v.endScale,lerpSpeed)
		v.currentRotation = lerp(v.currentRotation,v.endRotation,lerpSpeed)
		v.currentTranslation = lerp(v.currentTranslation,v.endTranslation,lerpSpeed)
		v.currentRotationPoint = lerp(v.currentRotationPoint,v.endRotationPoint,lerpSpeed)


		animator.resetTransformationGroup(i)
		animator.scaleTransformationGroup(i,v.baseScale)
		animator.translateTransformationGroup(i,v.baseTranslation)
		animator.translateTransformationGroup(i,vec2.mul(v.baseRotationPoint,-1))
		animator.rotateTransformationGroup(i,v.baseRotation)
		animator.translateTransformationGroup(i,v.baseRotationPoint)

		animator.scaleTransformationGroup(i,v.currentScale)
		animator.translateTransformationGroup(i,v.currentTranslation)
		animator.translateTransformationGroup(i,vec2.mul(v.currentRotationPoint,-1))
		animator.rotateTransformationGroup(i,v.currentRotation)
		animator.translateTransformationGroup(i,v.currentRotationPoint)
	end
end

groups = {
	weapon = {
		baseScale = 1,
		baseTranslation = {0,0},
		baseRotation = 0,
		baseRotationPoint = {0,0},
		endScale = 1,
		endTranslation = {0,0},
		endRotation = 0,
		endRotationPoint = {0,0}
	}
}

states = {
	idle = {
		nextStatePrimary = "primary1",
		nextStateAlt = "alt1",
		init = function(self)
			twoHanded = false
			groups.weapon.endTranslation = {0,2}
			groups.weapon.endRotationPoint = {0,0}
			groups.weapon.endScale = 1
			forcedArmAngle = -math.pi/2
			groups.weapon.endRotation = -math.pi / 16
			forcedFacingDirection = nil
			lerpSpeed = 8
			self.canCombo = true
		end,
		update = function(self,fireMode,shiftHeld)
			
		end,
		uninit = function(self)

		end
	},
	primary1 = {
		nextStatePrimary = "primary2",
		init = function(self)
			twoHanded = true
			groups.weapon.endTranslation = {0,2}
			groups.weapon.endRotation = math.rad(-10)
			groups.weapon.currentRotation = groups.weapon.endRotation
			groups.weapon.endRotationPoint = {0,0}
			groups.weapon.endScale = 1
			forcedArmAngle = math.pi/2
			armAngle = forcedArmAngle
			forcedFacingDirection = facingDirection
			lerpSpeed = 3
			self.timer = 0
			self.canCombo = false
		end,

		update = function(self,fireMode,shiftHeld)
			if self.timer == 8 then
				forcedArmAngle = math.rad(55)
				armAngle = forcedArmAngle -- instant move
				groups.weapon.endRotation = math.rad(-45)
				groups.weapon.currentRotation = groups.weapon.endRotation -- instant rotation
			end
			if self.timer == 9 then -- spawn swoosh a lil early

				-- swoosh stuff
				 -- gotten using inferion's very epic swoosh generator

				local downLine = {{3.11603,5.11249},{4.11603,3.52496},{4.20355,0.299988},{1.67853,-0.800049}}

				local connector = {{1.67853,-0.800049},{2.67786,-2.15002},{4.80286,-2.52502},{6.37549,-2.20831}}

				local upLine = {{6.37549,-2.20831},{8.21143,-0.291687},{6.50305,3.91663},{3.11603,5.11249}}


				local swoosh1 = getCurve(downLine,80)
				local swoosh2 = getCurve(connector,30)
				local swoosh3 = getCurve(upLine,80)

				-- make into 1 poly
				local swooshPoly = {}
				for i, v in ipairs(swoosh1) do
					if i ~= #swoosh1 then -- avoid overlap
						table.insert(swooshPoly,v)
					end
				end
				for i, v in ipairs(swoosh2) do
					if i ~= #swoosh2 then -- avoid overlap
						table.insert(swooshPoly,v)
					end
				end
				for i, v in ipairs(swoosh3) do
					table.insert(swooshPoly,v)
				end

				for i, v in ipairs(swooshPoly) do -- switch from relative pos to absolute position
					swooshPoly[i] = getRelPos(v)
				end

				spawnFireSwoosh(swooshPoly)
			end
			if self.timer == 11 then -- slash downwards, spawn swoosh
				animator.setSoundPitch("fireSwing",0.5)
				animator.setSoundVolume("fireSwing",1.3)
				animator.playSound("fireSwing")

				forcedArmAngle = -math.pi/4
				armAngle = forcedArmAngle -- instant move
				groups.weapon.endRotation = math.rad(-55)
				groups.weapon.currentRotation = groups.weapon.endRotation -- instant rotation
				forcedFacingDirection = nil
				self.canCombo = true
			end

			if self.timer == 31 then -- if no combos, then transition back
				changeState("idle")
			end

			--[[-- inferion's very epic swoosh visualizer
			if not points then
				points = {
					{0,0},
					{2,0},
					{2,2},
					{0,2}
				}
			end

			local mouseRelPos = activeItem.ownerAimPosition()
			mouseRelPos = vec2.sub(mouseRelPos,mcontroller.position())
			mouseRelPos = vec2.mul(mouseRelPos,{facingDirection,1})

			for i, v in ipairs(points) do
				world.debugPoint(getRelPos(v),"blue")
				if fireMode == "primary" and calcDist(activeItem.ownerAimPosition(),getRelPos(v)) < 0.2 then
					points[i] = mouseRelPos
				end
			end

			curveAltDown = curveAltDown or false


			-- print stuff to logs
			if fireMode == "alt" then
				curveAltDown = true
			else
				if curveAltDown then
					sb.logInfo(sb.printJson(points))
				end
				curveAltDown = false
			end

			local c = getCurve(points)

			for i, v in ipairs(c) do
				if i == #c then
					break
				end
				world.debugLine(getRelPos(v),getRelPos(c[i + 1]),"green")
			end
			]]

			self.timer = self.timer + 1
		end,

		uninit = function(self)
		end
	},
	primary2 = {
		nextStatePrimary = "primary3",
		init = function(self)
			twoHanded = true
			groups.weapon.endTranslation = {0,2}
			groups.weapon.endRotation = math.rad(-170)
			groups.weapon.currentRotation = groups.weapon.endRotation
			groups.weapon.endRotationPoint = {0,0}
			groups.weapon.endScale = 1
			forcedArmAngle = -math.pi/2
			armAngle = forcedArmAngle
			forcedFacingDirection = facingDirection
			self.timer = 0
			self.canCombo = false
			self.riseSpeed = 120
		end,

		update = function(self,fireMode,shiftHeld)
			if self.timer == 15 then -- slash upwards, spawn swoosh
				forcedArmAngle = math.pi/4
				armAngle = forcedArmAngle -- instant move
				groups.weapon.endRotation = math.rad(-125)
				groups.weapon.currentRotation = groups.weapon.endRotation -- instant rotation
				self.canCombo = false
			end
			if self.timer >= 15 and self.timer < 18 then -- player going up motion
				mcontroller.setVelocity({0,self.riseSpeed})
			end
			if self.timer == 16 then -- spawn swoosh a bit early


				-- spawn swoosh
				local upLine = {{2.90625,-9.4375},{4,-6.71875},{6.0625,-1.96875},{2.125,0.625}} -- upwards swoosh has upLine first

				local connector = {{2.125,0.625},{2.89063,1.67188},{5.03125,2.60938},{6.375,1.8125}} -- make sure edges all connect N' stuff

				local downLine = {{6.375,1.8125},{8.3125,-1.78125},{7.03125,-5.96875},{2.90625,-9.4375}}

				local swoosh1 = getCurve(upLine,140)
				local swoosh2 = getCurve(connector,30)
				local swoosh3 = getCurve(downLine,140)

				-- make into 1 poly
				local swooshPoly = {}
				for i, v in ipairs(swoosh1) do
					if i ~= #swoosh1 then -- avoid overlap
						table.insert(swooshPoly,v)
					end
				end
				for i, v in ipairs(swoosh2) do
					if i ~= #swoosh2 then -- avoid overlap
						table.insert(swooshPoly,v)
					end
				end
				for i, v in ipairs(swoosh3) do
					table.insert(swooshPoly,v)
				end

				local offset = vec2.mul(vec2.div({0,self.riseSpeed},60),2) -- convert to ticks then add 2, to get the end position

				for i, v in ipairs(swooshPoly) do -- switch from relative pos to absolute position
					swooshPoly[i] = getRelPos(v,offset)
				end

				spawnFireSwoosh(swooshPoly)
			end
			if self.timer == 18 then -- get ready for next combo
				self.canCombo = true
				forcedFacingDirection = nil
				self.freezePos = mcontroller.position()
				animator.setSoundPitch("fireSwing",0.5)
				animator.setSoundVolume("fireSwing",1.3)
				animator.playSound("fireSwing")
			end

			if self.timer >= 18 and self.timer <= 38 then -- freeze in air
				mcontroller.setVelocity({0,0})
				mcontroller.setPosition(self.freezePos)
			end

			if self.timer == 38 then -- if no comboes, then transition back
				changeState("idle")
			end
			self.timer = self.timer + 1
		end,

		uninit = function(self)
		end
	},
	primary3 = {
		nextStatePrimary = "primary4",
		init = function(self)
			self.canCombo = false
			self.freezePos = states.primary2.freezePos
			self.timer = 0
			groups.weapon.endRotation = -math.pi/2
			forcedFacingDirection = facingDirection
		end,

		update = function(self,fireMode,shiftHeld)
			if self.timer < 20 then -- do the rotate thingy
				mcontroller.setPosition(self.freezePos)
				mcontroller.setVelocity({0,0})
				local rotSpeed = 0.3
				forcedArmAngle = forcedArmAngle + rotSpeed
				if forcedArmAngle > math.pi * 2 then
					forcedArmAngle = 0
				end
				armAngle = forcedArmAngle -- force instant rotation
			end

			if self.timer == 18 then -- spawn swoosh somewhat early
				

				-- spawn swoosh
				local upLine = {{-6.49475,-2.84351},{-3.99475,-5.46851},{0.348999,-4.46851},{2.25525,-0.0935059}} -- upwards swoosh has upLine first

				local connector = {{2.25525,-0.0935059},{2.87701,1.35022},{4.97705,2.10022},{6.75525,1.90649}} -- make sure edges all connect N' stuff

				local downLine = {{6.75525,1.90649},{5.63025,-7.78101},{-3.2135,-9.49976},{-6.49475,-2.84351}}

				local swoosh1 = getCurve(upLine,200)
				local swoosh2 = getCurve(connector,30)
				local swoosh3 = getCurve(downLine,200)

				-- make into 1 poly
				local swooshPoly = {}
				for i, v in ipairs(swoosh1) do
					if i ~= #swoosh1 then -- avoid overlap
						table.insert(swooshPoly,v)
					end
				end
				for i, v in ipairs(swoosh2) do
					if i ~= #swoosh2 then -- avoid overlap
						table.insert(swooshPoly,v)
					end
				end
				for i, v in ipairs(swoosh3) do
					table.insert(swooshPoly,v)
				end

				for i, v in ipairs(swooshPoly) do -- switch from relative pos to absolute position
					swooshPoly[i] = getRelPos(v)
				end

				spawnFireSwoosh(swooshPoly)			
			end

			if self.timer == 20 then -- get ready for next combo and launch up just a lil' bit
				mcontroller.setVelocity({7 * facingDirection,20})
				self.canCombo = true
				forcedFacingDirection = nil
				animator.setSoundPitch("fireSwing",0.5)
				animator.setSoundVolume("fireSwing",1.3)
				animator.playSound("fireSwing")
			end


			if self.timer == 40 then
				changeState("idle")
			end

			self.timer = self.timer + 1
		end,

		uninit = function(self)

		end
	},
	primary4 = {
		nextStatePrimary = "primary5",
		init = function(self)
			twoHanded = true
			groups.weapon.endTranslation = {0,2}
			groups.weapon.endRotation = math.rad(-10)
			groups.weapon.currentRotation = groups.weapon.endRotation
			groups.weapon.endRotationPoint = {0,0}
			groups.weapon.endScale = 1
			forcedArmAngle = math.pi/2
			armAngle = forcedArmAngle
			forcedFacingDirection = facingDirection
			lerpSpeed = 3
			self.timer = 0
			self.canCombo = false
			self.downComplete = false
			self.downCompleteTime = nil
			self.slamVelocity = -75
		end,

		update = function(self,fireMode,shiftHeld)
			if self.timer == 8 then
				forcedArmAngle = math.rad(55)
				armAngle = forcedArmAngle -- instant move
				groups.weapon.endRotation = math.rad(-45)
				groups.weapon.currentRotation = groups.weapon.endRotation -- instant rotation
			end
			if self.timer >= 11 and not self.downComplete then
				mcontroller.setVelocity({0,self.slamVelocity})
				forcedArmAngle = -math.pi/4
				armAngle = forcedArmAngle -- instant move
				groups.weapon.endRotation = math.rad(-55)
				groups.weapon.currentRotation = groups.weapon.endRotation -- instant rotation
				if mcontroller.onGround() or self.timer == 30 then -- point at which down swing will finish no matter the on ground or not
					self.downComplete = true
					self.downCompleteTime = self.timer
				end
			end
			if self.downComplete and self.timer == self.downCompleteTime then -- slash downwards, spawn swoosh
				forcedFacingDirection = nil
				self.canCombo = true
				animator.setSoundPitch("fireSwing",0.5)
				animator.setSoundVolume("fireSwing",1.3)
				animator.playSound("fireSwing")


				-- swoosh stuff
				-- gotten using inferion's very epic swoosh generator

				local downLine = {{3.02476,11.2084},{5.27045,4.625},{3.47879,1},{1.67853,-0.800049}}

				local connector = {{1.67853,-0.800049},{2.67786,-2.15002},{4.80286,-2.52502},{6.37549,-2.20831}}

				local upLine = {{6.37549,-2.20831},{9.75393,3.45837},{7.46226,8.6875},{3.02476,11.2084}}


				local swoosh1 = getCurve(downLine,120)
				local swoosh2 = getCurve(connector,30)
				local swoosh3 = getCurve(upLine,120)

				-- make into 1 poly
				local swooshPoly = {}
				for i, v in ipairs(swoosh1) do
					if i ~= #swoosh1 then -- avoid overlap
						table.insert(swooshPoly,v)
					end
				end
				for i, v in ipairs(swoosh2) do
					if i ~= #swoosh2 then -- avoid overlap
						table.insert(swooshPoly,v)
					end
				end
				for i, v in ipairs(swoosh3) do
					table.insert(swooshPoly,v)
				end

				for i, v in ipairs(swooshPoly) do -- switch from relative pos to absolute position
					swooshPoly[i] = getRelPos(v)
				end

				spawnFireSwoosh(swooshPoly)
			end

			if self.downComplete and self.timer == self.downCompleteTime + 20 then -- if no combos, then transition back
				changeState("idle")
			end
			
			

			self.timer = self.timer + 1
		end,

		uninit = function(self)
		end
	},
	primary5 = {
		nextStatePrimary = "primary6",
		init = function(self)
			twoHanded = true
			groups.weapon.endTranslation = {0,2}
			groups.weapon.endRotation = math.pi/5
			--groups.weapon.currentRotation = groups.weapon.endRotation
			groups.weapon.endRotationPoint = {0,0}
			groups.weapon.endScale = 1
			forcedArmAngle = -2*math.pi/3
			--armAngle = forcedArmAngle
			forcedFacingDirection = facingDirection
			self.timer = 0
			self.canCombo = false
		end,
		update = function(self,fireMode,shiftHeld)
			if self.timer == 18 then -- slash upwards, spawn swoosh
				local frontCurve = {{2.80627,-0.662537},{3.8313,-0.637512},{4.49377,-0.987549},{5.59949,-1.53754}}
				local diagDown = {{5.59949,-1.53754},{6.29956,-1.15002},{6.76196,-0.850037},{7.3761,-0.450012}}
				local diagUp = {{7.3761,-0.450012},{6.85583,-0.0750122},{6.16833,0.375},{5.56836,0.737488}}
				local backCurve =  {{5.56836,0.737488},{4.49377,-0.212524},{3.7063,-0.650024},{2.80627,-0.662537}}

				-- swoosh stuff
				-- gotten using inferion's very epic swoosh generator


				local swoosh1 = getCurve(frontCurve,60)
				local swoosh2 = getCurve(diagDown,20)
				local swoosh3 = getCurve(diagUp,20)
				local swoosh4 = getCurve(backCurve,60)

				-- make into 1 poly
				local swooshPoly = {}
				for i, v in ipairs(swoosh1) do
					if i ~= #swoosh1 then -- avoid overlap
						table.insert(swooshPoly,v)
					end
				end
				for i, v in ipairs(swoosh2) do
					table.insert(swooshPoly,v)
				end
				for i, v in ipairs(swoosh3) do
					if i ~= #swoosh3 then -- avoid overlap
						table.insert(swooshPoly,v)
					end
				end
				for i, v in ipairs(swoosh4) do
					table.insert(swooshPoly,v)
				end

				for i, v in ipairs(swooshPoly) do -- switch from relative pos to absolute position
					swooshPoly[i] = getRelPos(v)
				end

				spawnFireSwoosh(swooshPoly,"middle")
			end

			if self.timer == 20 then
				animator.setSoundPitch("fireStab",0.7)
				animator.setSoundVolume("fireStab",1.2)
				animator.playSound("fireStab")

				forcedArmAngle = -math.pi/8
				armAngle = forcedArmAngle -- instant move
				groups.weapon.endRotation = math.rad(-65)
				groups.weapon.currentRotation = groups.weapon.endRotation -- instant rotation
				forcedFacingDirection = nil
				self.canCombo = true
			end

			if self.timer == 40 then
				changeState("idle")
			end

			self.timer = self.timer + 1
		end,
		uninit = function(self)
		end
	},
	primary6 = {
		init = function(self)
			twoHanded = true
			groups.weapon.endTranslation = {0,2}
			--groups.weapon.currentRotation = groups.weapon.endRotation
			groups.weapon.endRotationPoint = {0,0}
			groups.weapon.endScale = 1
			forcedArmAngle = math.pi/5
			groups.weapon.endRotation = -5.5*math.pi/5
			lerpSpeed = 9
			--armAngle = forcedArmAngle
			forcedFacingDirection = facingDirection
			self.timer = 0
			self.canCombo = false

			self.volcanoRiseTime = 65
			self.volcanoDelayTime = 24
			self.volcanoCount = 3
		end,

		update = function(self,fireMode,shiftHeld)
			if self.timer == 30 then
				forcedArmAngle = -math.pi/5
				armAngle = forcedArmAngle -- instant move
				groups.weapon.endRotation = -3.5*math.pi/5
				groups.weapon.currentRotation = groups.weapon.endRotation -- instant rotation
				self.canCombo = true
				self.freezePos = mcontroller.position()

				animator.setSoundPitch("groundPierce",0.7)
				animator.setSoundVolume("groundPierce",1.5)
				animator.playSound("groundPierce")

				local crackStart = getRelPos({1.19,-2.4})
				crackStart = world.lineCollision(crackStart,vec2.add(crackStart,{0,-4})) or crackStart
				crackStart = vec2.add(crackStart,{0,-0.1})

				self.crackLines = {}
				self.crackDistance = 8 -- used for line width calculation later

				local spreadAngle = 2*math.pi/3
				local numCracks = 5

				for i = 1, numCracks do
					local curAngle = -math.pi/2 + (spreadAngle/numCracks*i) - (spreadAngle/2)
					local newCracks = getCrackLines(crackStart,
					curAngle, -- starting angle
					self.crackDistance, -- total distance of each branch path
					0.1, -- probability of brance per block
					math.pi/3, -- angle of each branch
					math.pi/2) -- angle of each tilt
					for _, v in ipairs(newCracks) do
						table.insert(self.crackLines,v)
					end
				end

			end

			if self.timer > 30 then
				mcontroller.setPosition(self.freezePos)
				mcontroller.setVelocity({0,0})
			end

			local repeatTime = 2.9 -- in seconds

			if self.timer >= 30 and (self.timer - 30) % (math.floor(repeatTime * 60)) == 0 then -- every x ticks, starting at tick 30
				local lineActions = {}
				local pixPerBlock = 5
				for i, v in ipairs(self.crackLines) do -- spawning the cracks with 6 am code
					for j = 1, pixPerBlock do
						-- TODO: see if j vs j - 1 matters
						-- v.sWidth + ((v.eWidth - s.eWidth)/pixPerBlock*j) / self.crackDistance
						local widthMultiplier = 0.3 -- how wide the widest one is
						local widthPercentage = (v.sWidth + ((v.eWidth - v.sWidth)/pixPerBlock*j)) / self.crackDistance
						local width = widthPercentage * widthMultiplier -- fukin math (written by 4:31 am inferion)
						local cPoint = vec2.add(vec2.mul(vec2.div(vec2.sub(v.endPos,v.startPos),pixPerBlock),j-1),v.startPos) -- even more fukin math (written by 4:33 am inferion)
						local iAngle = math.atan(v.endPos[2] - v.startPos[2],v.endPos[1] - v.startPos[1]) -- stands for "initial angle" i think
						local p1 = vec2.withAngle(iAngle - math.pi/2,width/2)
						local p2 = vec2.withAngle(iAngle + math.pi/2,width/2)
						p1 = vec2.add(p1,cPoint)
						p2 = vec2.add(p2,cPoint)
						-- make relative to player position, then spawn on player
						p1 = vec2.sub(p1,self.freezePos)
						p2 = vec2.sub(p2,self.freezePos)
						local newAction = getLineAction(p1,p2,"000000","front",1.6,repeatTime,false)
						newAction["repeat"] = false
						newAction.specification.destructionAction = "fade"
						newAction.specification.destructionTime =  0.8 * (1-widthPercentage)  -- a little extra time for the cracks to go away
						table.insert(lineActions,newAction)

						local magmaColor1 = "ff8000"
						local magmaColor2 = "8b0000"
						local magmaPercentage = (1 - widthPercentage) -- we do 1 - widthPercentage so that it flows top to bottom

						local magmaAction = getLineAction(p1,p2,color.transHex(magmaColor1,magmaColor2,magmaPercentage),"front",1.6,0.8,false,magmaPercentage * 2)
						magmaAction["repeat"] = false
						local r, g, b = color.hex2rgb(color.transHex(magmaColor1,magmaColor2,magmaPercentage))
						magmaAction.specification.light = {r,g,b}
						table.insert(lineActions,magmaAction)
					end
				end
				world.spawnProjectile("boltguide",mcontroller.position(),activeItem.ownerEntityId(),{0,0},false,{
					timeToLive = repeatTime,
					persistentAudio = "/assetmissing.wav",
					processing = "?multiply=FFFFFF00",
					damageType = "NoDamage",
					movementSettings = {
						collisionPoly = jarray(),
						collisionEnabled = false
					},
					periodicActions = lineActions
				})				
			end

			self.volcanoSpawnTime = 30 + math.floor(repeatTime*60 * 0.25)

			if self.timer == self.volcanoSpawnTime then -- spawn the volcano during the first lava flow
				local volcanoImageList = {
					"/objects/floran/plantvolcano2/plantvolcano2.png",
					"/objects/floran/plantvolcano3/plantvolcano3.png",
					"/objects/floran/plantvolcano4/plantvolcano4.png"
				}
				self.volcanoIds = {}
				local volcanoOffsetDist = 4 -- number of blocks between volcanoes (in X direction)
				local volcanoStartOffset = {4,0} -- distance from player for the first volcano (offset before ground detection)
				local volcanoRiseAmount = 1.6

				local lastSpawn = vec2.add(mcontroller.position(),vec2.mul(volcanoStartOffset,{facingDirection,1}))

				for i = 1, self.volcanoCount do
					local spawnPos = nil
					if i == 1 then
						spawnPos = lastSpawn
					else
						spawnPos = vec2.add(lastSpawn,{volcanoOffsetDist * facingDirection,0})
					end
					if world.pointCollision(spawnPos) then
						spawnPos = world.lineCollision(vec2.add(spawnPos,{0,7}),spawnPos) -- go from the top down to find top of ground
					else
						spawnPos = world.lineCollision(spawnPos,vec2.add(spawnPos,{0,-7})) or spawnPos -- go from top down to find possible ground
					end
					lastSpawn = spawnPos

					spawnPos = vec2.add(spawnPos,{0,-1}) -- offset after ground detection

					local image = volcanoImageList[i]
					table.insert(self.volcanoIds,world.spawnMonster("mechshielddrone",spawnPos,{ -- spawn controller with standard parameters
						scripts = {"/inferno/volcanoMonster.lua"},
						animationScripts = {"/items/active/effects/chain.lua"},
						statusSettings = {
							primaryScriptSources = {
								"/inferno/volcanoMonsterStatus.lua"
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
														image = image
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
							sounds = {
								rumble = {"/sfx/tools/chainsaw_cut_wood.ogg"},
								erupt = {"/sfx/gun/rocketblast1.ogg","/sfx/gun/rocketblast2.ogg","/sfx/gun/rocketblast3.ogg"}
							},
							lights = {
								volcano = {
									color = {255,156,0},
									position = {0,0},
									active = true
								}
							}
						},
						parentId = activeItem.ownerEntityId(),
						delayTime = self.volcanoDelayTime * (i - 1),
						riseAmount = volcanoRiseAmount,
						riseTime = self.volcanoRiseTime
					}))
				end
			end

			if self.timer == self.volcanoSpawnTime + self.volcanoRiseTime + (self.volcanoDelayTime * (self.volcanoCount - 1)) then
				if self.volcanoIds then -- make dem monsters erupt
					for i, v in ipairs(self.volcanoIds) do
						if world.entityExists(v) then
							world.sendEntityMessage(v,"erupt")
						end
					end
				end				
			end

			if fireMode ~= "primary" and fireMode ~= "alt" and self.timer > 30 then -- this is a "click and hold" ability
				changeState("idle")
			end


			self.timer = self.timer + 1
		end,
		uninit = function(self)
			if self.volcanoIds then -- kill the volcano monsters
				for i, v in ipairs(self.volcanoIds) do
					if world.entityExists(v) then
						world.sendEntityMessage(v,"despawn")
					end
				end
			end
		end
	},
	alt1 = {
		canCombo = false,
		init = function(self)
			twoHanded = false
			groups.weapon.endTranslation = {0,2}
			groups.weapon.endRotation = math.rad(-170)
			groups.weapon.currentRotation = groups.weapon.endRotation
			groups.weapon.endRotationPoint = {0,0}
			groups.weapon.endScale = 1
			forcedArmAngle = -math.pi/2 - math.pi/8
			armAngle = forcedArmAngle
			forcedFacingDirection = facingDirection
			self.timer = 0
			self.canCombo = false
		end,
		update = function(self,fireMode,shiftHeld)
			if self.timer == 13 then
				-- swoosh stuff
				-- gotten using inferion's very epic swoosh generator

				local upLine = {{-6.92556,0},{-4.43806,-1.30005},{-0.500557,-0.662598},{1.09944,1}}
				local connector = {{1.09944,1},{1.44108,2.25},{4.51608,2.71252},{5.73694,2.32495}}
				local downLine = {{5.73694,2.32495},{3.63694,-4.29993},{-3.42556,-6.28748},{-6.92556,0}}
				local swoosh1 = getCurve(upLine,140)
				local swoosh2 = getCurve(connector,30)
				local swoosh3 = getCurve(downLine,140)

				-- make into 1 poly
				local swooshPoly = {}
				for i, v in ipairs(swoosh1) do
					if i ~= #swoosh1 then -- avoid overlap
						table.insert(swooshPoly,v)
					end
				end
				for i, v in ipairs(swoosh2) do
					if i ~= #swoosh2 then -- avoid overlap
						table.insert(swooshPoly,v)
					end
				end
				for i, v in ipairs(swoosh3) do
					table.insert(swooshPoly,v)
				end

				for i, v in ipairs(swooshPoly) do -- switch from relative pos to absolute position
					swooshPoly[i] = getRelPos(v)
				end

				spawnFireSwoosh(swooshPoly)
			end
			if self.timer == 15 then
				forcedArmAngle = math.pi/2
				armAngle = forcedArmAngle -- instant move
				groups.weapon.endRotation = math.rad(-170)
				groups.weapon.currentRotation = groups.weapon.endRotation -- instant rotation
				self.canCombo = true
				animator.setSoundPitch("fireSwing",0.7)
				animator.setSoundVolume("fireSwing",1.2)
				animator.playSound("fireSwing")

				local projAmp = 0.75

				local spawnPos = vec2.add(mcontroller.position(),{0 * facingDirection,0})
				
				local projParameters = {
					waveAmplitude = 0.75,
					speed = 20,
					timeToLive = 20,
					processing = "?scalenearest=0",
					periodicActions = {{
						action = "particle",
						["repeat"] = true,
						time = 0.01,
						specification = {
							type = "animated",
							animation = getFireAnimation("ff8000","ffffff"),
							timeToLive = 0.75,
							size = 1.2,
							destructionTime = 0.5,
							destructionAction = "shrink",
							finalVelocity = {0,0},
							approach = {3,3},
							variance = {
								position = {0.2,0.2},
								initialVelocity = {5,5},
								size = 0.3
							}
						}
					}}
				}

				world.spawnProjectile("wobbleshot",spawnPos,activeItem.ownerEntityId(),{facingDirection,0},false,projParameters)

				spawnPos = vec2.add(spawnPos,{0,projParameters.waveAmplitude})
				projParameters.waveAmplitude = -projParameters.waveAmplitude

				world.spawnProjectile("wobbleshot",spawnPos,activeItem.ownerEntityId(),{facingDirection,0},false,projParameters)
				
			end

			if self.timer == 25 then
				changeState("idle")
			end
			self.timer = self.timer + 1

		end,
		uninit = function(self)
		end
	}
}

function getCurve(curvePoints,steps)
	local steps = steps or 20
	return Bezier.createCubicCurve(curvePoints[1],curvePoints[2],curvePoints[3],curvePoints[4], steps)
end

function spawnFireSwoosh(inpPoly,renderLayer) 
	inpPoly = poly.translate(inpPoly,vec2.mul(mcontroller.position(),{-1,-1})) -- convert back to relative player position

	local renderLayer = renderLayer or "back"
	local totTimeToLive = 0.2

	local baseSwoosh = {}

	local swooshLayers = { -- outside to inside
		{
			size = 1,
			colors = {"ad3202","c75c0a"} -- bottom to top
		},
		{
			size = 0.95,
			colors = {"d46c04","ff8000"}
		},
		{
			size = 0.9,
			colors = {"f7d200","edf520"}
		},
		{
			size = 0.85,
			colors = {"f6ff00","ffffff"}
		}
	}


	for i = 1, #inpPoly/2 do
		local p1 = inpPoly[i]
		local p2 = inpPoly[#inpPoly - i + 1] -- get points from end
		table.insert(baseSwoosh,{p1,p2})
	end


	local actions = {}

	local bmPos = vec2.div(vec2.add(baseSwoosh[#baseSwoosh][1],baseSwoosh[#baseSwoosh][2]),2) -- bottom middle position on outermost swoosh

	local offsets = {} -- offsets to get bottom middles to line up

	for i, v in ipairs(swooshLayers) do
		table.insert(offsets,vec2.mul(bmPos,1 - v.size))
	end

	table.insert(actions,{
		action = "particle",
		time = 0,
		specification = {
			type = "textured",
			image = "/assetmissing.png",
			position = bmPos,
			timeToLive = totTimeToLive,
			light = {255,156,0}
		}
	})

	for j, l in ipairs(swooshLayers) do -- nested loop, l stands for layer
		for i, v in ipairs(baseSwoosh) do
			local percentage = i / #baseSwoosh
			local ttl = percentage * totTimeToLive
			local newCol = color.transHex(l.colors[1],l.colors[2],percentage)
			local newAction = getLineAction(vec2.add(vec2.mul(v[1],l.size),offsets[j]),vec2.add(vec2.mul(v[2],l.size),offsets[j]),newCol,renderLayer,1,ttl)
			newAction.specification.destructionAction = "fade"
			newAction.specification.destructionTime = 0.2
			table.insert(actions,newAction)
		end
	end

	for i, v in ipairs(baseSwoosh) do -- flame puff particles
		if math.random(25) == 1 then
			local percentage = math.random()
			local endPos = vec2.add(vec2.mul(vec2.sub(v[2],v[1]),percentage),v[1]) -- get random point along the line
			table.insert(actions,{ -- spawn flame puff particle
				action = "particle",
				time = 0,
				specification = {
					type = "animated",
					animation = "/animations/flamepuff/flamepuff.animation",
					size = 0.3,
					fullbright = true,
					timeToLive = 2.8,
					layer = "middle",
					variance = {
						rotation = 360
					},
					position = endPos
				}
			})
		end
	end

	for i, v in ipairs(baseSwoosh) do -- fire particles
		local probLow = 7
		local probHigh = 2
		local percentage = i/#baseSwoosh -- gets less likely the further down it gets
		local probability = (probLow - probHigh) * percentage + probLow
		if math.random(math.floor(probability)) == 1 then
			local posPercent = math.random()
			local endPos = vec2.add(vec2.mul(vec2.sub(v[2],v[1]),posPercent),v[1]) -- get random point along the line

			local particleConfig = root.assetJson("/particles/burningdust.particle").definition
			particleConfig.layer = "middle"
			particleConfig.fullbright = true
			particleConfig.position = endPos
			particleConfig.variance.rotation = 10
			particleConfig.light = {156,64,0}

			table.insert(actions,{ -- spawn flame puff particle
				action = "particle",
				time = 0,
				specification = particleConfig
			})
		end
	end

	for i, v in ipairs(baseSwoosh) do -- smoke particles
		local probLow = 20
		local probHigh = 1
		local percentage =  1 - (i/#baseSwoosh) -- gets more likely the further down it gets
		local probability = (probLow - probHigh) * percentage + probLow
		if math.random(math.floor(probability)) == 1 then
			local posPercent = math.random()
			local endPos = vec2.add(vec2.mul(vec2.sub(v[2],v[1]),posPercent),v[1]) -- get random point along the line

			local curMid = nil
			local nextMid = nil
			if i == #baseSwoosh then -- breaks if your curve has only 1 line but fucking McDon't (comment written by 6:35 am Inferion)
				curMid = vec2.div(vec2.add(baseSwoosh[i - 1][1],baseSwoosh[i - 1][2]),2)
				nextMid = vec2.div(vec2.add(v[1],v[2]),2)
			else
				curMid = vec2.div(vec2.add(v[1],v[2]),2)
				nextMid = vec2.div(vec2.add(baseSwoosh[i + 1][1],baseSwoosh[i + 1][2]),2)
			end

			local angle = math.atan(nextMid[2]-curMid[2],nextMid[1]-curMid[1]) -- to make the particle move in the direction of the swoosh


			local particleConfig = root.assetJson("/particles/smoke.particle").definition
			particleConfig.layer = "middle"
			particleConfig.size = 0.5
			particleConfig.animation = "/animations/statuseffects/burning2/burning2.animation"
			particleConfig.position = endPos
			particleConfig.velocity = vec2.withAngle(angle,5) -- to make the particle move in the direction of the swoosh
			particleConfig.initialVelocity = nil
			particleConfig.finalVelocity = nil
			particleConfig.variance = nil

			table.insert(actions,{ -- spawn flame puff particle
				action = "particle",
				time = 0,
				specification = particleConfig
			})
		end
	end

	local longestTime = 0

	for i, v in ipairs(actions) do
		actions[i]["repeat"] = false
		longestTime = math.max(longestTime,v.time)
	end


	world.spawnProjectile("boltguide",mcontroller.position(),activeItem.ownerEntityId(),{0,0},false,{
		timeToLive = longestTime + 0.02,
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

function getLineAction(_point1,_point2,color,_layer,size,timeToLive,fullbright,delay)
	local _layer = _layer or "front"
	local color = color or "ffffff"
	local size = size or 1
	local timeToLive = timeToLive or 1
	local fullbright = fullbright or true
	local delay = delay or 0
	return {
		action = "particle",
		time = delay,
		specification = {
			type = "streak",
			layer = _layer,
			fullbright = fullbright,
			collidesForeground = false,
			size = size,
			color = "#" .. color,
			timeToLive = timeToLive,
			velocity = {
				world.distance(_point1,_point2)[1] * 0.01,
				world.distance(_point1,_point2)[2] * 0.01			
			},
			length = world.magnitude(_point1, _point2) * 8, -- convert blocks to pixels
			position = _point1,
			variance = {
				length = 0
			}
		}
	}
end

function getFireAnimation(color1,color2)
	return "/animations/ember1/ember1.animation?crop=1;2;2;3?replace;fd8f4d=" .. color1 .. ";da5302=" .. color2 .. ";fdd14d=" .. color2
end

function getCrackLines(startPos,angle,totDistance,branchProb,branchAngle,tiltAngle) -- couldn't think of a better name than "tilt angle" for the angle that each crack changes per step
	local endLines = {}
	local underGround = true
	if not world.pointCollision(startPos) then
		underGround = false
	end
	local function progressLine(startPos,angle,distanceLeft)
		-- progress one block at a time
		local endPos = vec2.add(startPos,vec2.withAngle(angle,1))
		if (not world.pointCollision(endPos)) and underGround then
			endPos = world.lineCollision(endPos,startPos)
			if not endPos then
				return
			end
		end
		table.insert(endLines,{
			startPos = startPos,
			endPos = endPos,
			sWidth = distanceLeft,
			eWidth = distanceLeft - 1
		})
		if distanceLeft - 1 > 0 then
			local nAngle = angle + randomInRange(tiltAngle)
			progressLine(endPos,nAngle,distanceLeft - 1)
			if math.random() <= branchProb then
				nAngle = angle + randomInRange(branchAngle) -- reusing variable names is maybe bad practice
				progressLine(endPos,nAngle,distanceLeft - 1)
			end
		end
	end
	progressLine(startPos,angle,totDistance)
	return endLines
end

-- util functions
function randomInRange(range)
    return -range + math.random() * 2 * range
end

function randomOffset(range)
    return {randomInRange(range), randomInRange(range)}
end

function lerp(from, to, ratio)
	if type(from) == "table" or type(from) == "array" then --bam, lerping vectors and recursive function
		return {lerp(from[1],to[1],ratio),lerp(from[2],to[2],ratio)}
	else
		return (from + ((to - from) / ratio))
	end
end

function getRelPos(inpVec,offset) -- input a position and it'll rotate, add hand pos, flip, ect
	local offset = offset or {0,0}
	return vec2.add(vec2.add(vec2.mul(inpVec,{facingDirection,1}),mcontroller.position()),offset)
end

function calcDist(vectorA,vectorB)
    local xDist = vectorA[1] - vectorB[1]
    local yDist = vectorA[2] - vectorB[2]
    return math.sqrt(xDist ^ 2 + yDist ^ 2)
end
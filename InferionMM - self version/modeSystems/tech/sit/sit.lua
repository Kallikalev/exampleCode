require "/scripts/vec2.lua"

local moveSpeed = 0.25
local shiftMoveSpeed = 0.125

function sitInit()
	Bind.create("specialOne up",toggleSit,false)
end

function sitUpdate(args)
	if self.sitActive then
		if args.moves["run"] then
			if args.moves["up"] then
				self.savedPos[2] = self.savedPos[2] + moveSpeed
			end
			if args.moves["down"] then
				self.savedPos[2] = self.savedPos[2] - moveSpeed
			end
			if args.moves["left"] then
				self.savedPos[1] = self.savedPos[1] - moveSpeed
			end
			if args.moves["right"] then
				self.savedPos[1] = self.savedPos[1] + moveSpeed
			end
		else
			if args.moves["up"] then
				self.savedPos[2] = self.savedPos[2] + shiftMoveSpeed
			end
			if args.moves["down"] then
				self.savedPos[2] = self.savedPos[2] - shiftMoveSpeed
			end
			if args.moves["left"] then
				self.savedPos[1] = self.savedPos[1] - shiftMoveSpeed
			end
			if args.moves["right"] then
				self.savedPos[1] = self.savedPos[1] + shiftMoveSpeed
			end
		end

		self.stateControlled = true
		self.savedState = "Sit"
		mcontroller.setVelocity({0,0})
		mcontroller.setPosition(self.savedPos)
	end
end

function sitUninit()
end

function toggleSit()
	if self.sitActive then
		self.sitActive = false
	else
		self.sitActive = true
		self.noclipActive = false
		self.noclipClassicActive = false
		self.savedPos = mcontroller.position()
	end
end
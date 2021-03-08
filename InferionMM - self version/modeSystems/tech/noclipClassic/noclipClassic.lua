require "/scripts/vec2.lua"


local moveSpeed = 1
local shiftMoveSpeed = 0.5

function noclipClassicInit()
	Bind.create("specialOne down",toggleNoclip,false)
end

function toggleNoclip()
	if self.noclipClassicActive then
		self.noclipClassicActive = false
	else
		self.noclipClassicActive = true
		self.noclipActive = false
		self.sitActive = false
		savedOffset = mcontroller.position()
	end
end

function noclipClassicUpdate(args)
	if self.noclipClassicActive then
		if args.moves["run"] then
			if args.moves["up"] then
				savedOffset[2] = savedOffset[2] + moveSpeed
			end
			if args.moves["down"] then
				savedOffset[2] = savedOffset[2] - moveSpeed
			end
			if args.moves["left"] then
				savedOffset[1] = savedOffset[1] - moveSpeed
			end
			if args.moves["right"] then
				savedOffset[1] = savedOffset[1] + moveSpeed
			end
		else
			if args.moves["up"] then
				savedOffset[2] = savedOffset[2] + shiftMoveSpeed
			end
			if args.moves["down"] then
				savedOffset[2] = savedOffset[2] - shiftMoveSpeed
			end
			if args.moves["left"] then
				savedOffset[1] = savedOffset[1] - shiftMoveSpeed
			end
			if args.moves["right"] then
				savedOffset[1] = savedOffset[1] + shiftMoveSpeed
			end
		end

		self.stateControlled = true
		self.savedState = "Stand"
		mcontroller.setVelocity({0,0})
		mcontroller.setPosition(savedOffset)
	end
end

function noclipClassicUninit()
end
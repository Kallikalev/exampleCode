local sizeMax = 2.5
local sizeMin = 0.4

local rotSpeed = 3
local sizeSpeed = 0.01

local lastRotation = 0

function rotSizeInit()
	tech.appendDirectives("size","",0)

	Bind.create("specialTwo up",sizeUp,true)
	Bind.create("specialTwo down",sizeDown,true)
	Bind.create("specialTwo left",rotLeft,true)
	Bind.create("specialTwo right",rotRight,true)

	Bind.create("specialTwo shift",resetRotSize,false)
end

function rotSizeUpdate(args)
	tech.updateDirectives("size","?scalenearest=" .. tostring(self.savedSize))
	if self.savedRotation ~= lastRotation then
		mcontroller.setRotation(math.rad(self.savedRotation))
	end
	lastRotation = self.savedRotation
end

function rotSizeUninit()
end

function sizeUp()
	local newSize = self.savedSize + sizeSpeed
	if newSize <= sizeMax then
		self.savedSize = newSize
	end
end

function sizeDown()
	local newSize = self.savedSize - sizeSpeed
	if newSize >= sizeMin then
		self.savedSize = newSize
	end
end

function rotLeft()
	self.savedRotation = self.savedRotation + rotSpeed
end

function rotRight()
	self.savedRotation = self.savedRotation - rotSpeed
end

function resetRotSize()
	self.savedSize = 1
	self.savedRotation = 0

	local restoredPos = world.resolvePolyCollision(mcontroller.baseParameters().standingPoly, mcontroller.position(), 2.5)
	self.savedPos = restoredPos
	mcontroller.setPosition(restoredPos)
end
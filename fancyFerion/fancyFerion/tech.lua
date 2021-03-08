require "/scripts/vec2.lua"
require "/scripts/poly.lua"
require "/fancyFerion/Color.lua"
require "/fancyFerion/Base64.lua"

standardPersonality = {
	bodyIdle = "idle.3",
	armIdle = "idle.3",
	headOffset = {-1,0},
	armOffset = {0,0}
}



function init()
	require "/scripts/keybinds.lua"
    require "/scripts/techDirectives.lua"

	status.setStatusProperty("fancyFerionActive",true)

	status.setStatusProperty(status.statusProperty("fancyFerionCurrentIdentity",1))
	currentIdentity = status.statusProperty("fancyFerionCurrentIdentity",1)

	identityList = root.assetJson("/fancyFerion/modules/identityController/identityList.json")

    self.savedPos = mcontroller.position()

	require "/dllUtils.lua"


    modules = {}
    moduleDirectoryFilepath = [[..\mods\fancyFerion\fancyFerion\modules\]] -- double brackets are basically super quotes
    
    if io then
        moduleNames = scandir(moduleDirectoryFilepath)
    else
        moduleNames = root.assetJson("/fancyFerion/modules.json").names
    end

	firstTick = false
end

function update(args)

	if not firstTick then
		loadPointers()
		firstTick = true

		for i, v in ipairs(moduleNames) do -- load in all the commands
			require("/fancyFerion/modules/" .. v .. "/" .. v .. ".lua") -- command file locations should *always* follow this pattern
		end

		for i, v in ipairs(moduleNames) do
			if _ENV[v .. "Init"] then
				_ENV[v .. "Init"]()
			end
		end
	end

	for i, v in ipairs(moduleNames) do
		if _ENV[v .. "Update"] then
			_ENV[v .. "Update"](args)
		end
	end


	-- local t = 50
	-- if args.moves.run then
	-- 	for x = mcontroller.position()[1]-t, mcontroller.position()[1]+t do
	-- 		for y = mcontroller.position()[2]-t, mcontroller.position()[2]+t do
	-- 			local matNum = dll.material(x,y,"foreground")
	-- 			if matNum < 10000 then
	-- 				-- world.debugPoint({x,y},"red")
	-- 			end
	-- 		end
	-- 	end
	-- end
	

end

function uninit()
	for i, v in ipairs(moduleNames) do
		if _ENV[v .. "Uninit"] then
			_ENV[v .. "Uninit"]()
		end
	end

	status.setStatusProperty("fancyFerionActive",false)

end

-- Lua implementation of PHP scandir function, https://stackoverflow.com/questions/5303174/how-to-get-list-of-directories-in-lua
function scandir(directory) -- finds all the directories in a directory, super duper useful
	local t = {}
	for dir in io.popen([[dir "]] .. directory .. [[" /b /ad]]):lines() do
		table.insert(t,dir)
	end
    return t
end
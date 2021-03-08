local ini = init or function() end
local upd = update or function() end
local unini = uninit or function() end

function init()
	ini()
	message.setHandler("testBowAddDrawable",function(_, clientSender, drawable, layer)
		if clientSender then
			localAnimator.addDrawable(drawable,layer)
		end
	end)
end

function update(...)
	upd(...)
end

function uninit()
	unini()
end
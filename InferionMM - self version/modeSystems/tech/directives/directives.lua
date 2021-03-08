function directivesInit()
	tech.appendDirectives("directives","",0)
end

function directivesUpdate()
	local directives = self.modeSystemsConfig.modes[self.mode].directives or ""
	tech.updateDirectives("directives",directives)
end

function directivesUninit()
end
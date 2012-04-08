if nil ~= require then
	require "fritomod/currying";
	require "fritomod/Functions";
end;

Slash = setmetatable({}, {
	__newindex = function(self, name, listener)
		if type(name) == "table" then
			for _, subname in ipairs(name) do
				self[subname] = listener;
			end;
			return;
		end;
		assert(string.upper(name) ~= "RUN", "'/run' slash command cannot be overwritten");
		assert(string.upper(name) ~= "DUMP", "'/dump' slash command cannot be overwritten");
		assert(string.upper(name) ~= "SCRIPT", "'/script' slash command cannot be overwritten");
		if not listener then
			slashListeners[name] = nil;
		end;
		assert(IsCallable(listener), "Slash listener must be callable, but it was a " .. type(listener));
		if SlashCmdList then
			local upper=string.upper(name);
			SlashCmdList[upper]=function(...)
				-- This function must be nested, since Blizzard makes the underlying slash listener immutable
				-- once it's first set.
				local listener = Slash[name];
				if listener then
					listener(...);
				end;
			end;
			local i=1;
			while _G["SLASH_"..upper..i] do
				i=i+1;
			end;
			_G["SLASH_"..upper..i]="/"..name;
		end;
		rawset(self, name, listener);
	end
});

rawset(Slash, "Run", function(cmd, ...)
	local listener=Slash[cmd];
	if IsCallable(listener) then
		-- Ordinarily, we would assert that the listener's callable. However, I'd rather it be tolerant of
		-- misspellings since WoW's slash command is also tolerant.
		listener(...);
	end;
end);

--[[[
-- Register the specified handler for the slash command specified by name.
-- If name is foo, then "/foo" will run the specified handler.
--
-- This function is equivalent to "Slash[name] = Curry(handler, ...);" and this
-- simpler form should be used instead.
--]]
rawset(Slash, "Register", function(name, handler, ...)
	handler=Curry(handler,...);
	if type(name)=="table" then
		for i=1,#name do
			Slash.Register(name[i], handler);
		end;
		return;
	end;
	Slash[name] = handler;
end);

--[[
-- Register all specified names to the specified handler. This function is the equivalent of "Slash[{...}] = handler"
-- and this simpler form should be used instead.
--]]
function RegisterSlash(handler, ...)
	return Slash.Register({...},handler);
end;

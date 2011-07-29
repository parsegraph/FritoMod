if nil ~= require then
	require "fritomod/currying";
	require "fritomod/Functions";
end;
Slash={
	Registry={}
};

function Slash.Run(cmd, ...)
	local h=Slash.Registry[cmd];
	if not h then
		error("cmd must match a registered handler: "..cmd);
	end;
	h(...)
end;

function Slash.Register(name, handler, ...)
	handler=Curry(handler,...);
	if type(name)=="table" then
		for i=1,#name do
			Slash.Register(name[i], handler);
		end;
		return;
	end;
	Slash.Registry[name] = handler;
	if SlashCmdList then
		local upper=string.upper(name);
		SlashCmdList[upper]=function(...)
			-- This must be nested, since this value is saved and immutable
			-- once it's first used.
			Slash.Registry[name](...);
		end;
		local i=1;
		while _G["SLASH_"..upper..i] do
			i=i+1;
		end;
		_G["SLASH_"..upper..i]="/"..name;
	end;
	return Functions.OnlyOnce(function()
		Slash.Registry[name]=nil;
	end);
end;

function RegisterSlash(handler, ...)
	return Slash.Register({...},handler);
end;

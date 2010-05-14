if nil ~= require then
	require "FritoMod_Functional/currying";
	require "FritoMod_Functional/Functions";
end;
Slash={
	Registry={}
};

function Slash.Run(cmd, ...)
	local h=Slash.Registry[string.lower(cmd)];
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
	Slash.Registry[string.lower(name)] = handler;
	local remover=Functions.OnlyOnce(function()
		Slash.Registry[string.lower(name)]=nil;
	end);
	if SlashCmdList then
		local upper=string.upper(name);
		-- Set it to nil to force __newindex to fire on our new handler
		SlashCmdList[upper]=nil;
		SlashCmdList[upper]=handler;
		i=1;
		while _G["SLASH_"..upper..i] do
			i=i+1;
		end;
		_G["SLASH_"..upper.i]="/"..name;
		return Functions.OnlyOnce(function()
			_G["SLASH_"..upper.i]=nil;
			SlashCmdList[upper]=nil;
			remover();
		end);
	else
		return remover;
	end;
end;

function RegisterSlash(handler, ...)
	return Slash.Register({...},handler);
end;

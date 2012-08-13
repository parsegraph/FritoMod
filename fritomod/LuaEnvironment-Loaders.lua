if nil ~= require then
    require "fritomod/LuaEnvironment";
end;

LuaEnvironment.Loaders={};
local loaders=LuaEnvironment.Loaders;

function loaders.Filesystem(loader, env, package)
	return function(env, package)
		local file=package;
		if not file:find("\.lua$") then
			file=package..".lua";
		end;
		local runner, err=loader(file);
		if runner then
			return runner;
		end;
		return nil, err;
	end;
end;

function loaders.Ignore(...)
	local ignored={...};
	return function(env, package)
		for i=1, #ignored do
			if package==ignored[i] then
				return false;
			end;
		end;
	end;
end;

-- vim: set noet :

if nil ~= require then
    require "fritomod/basic";
    require "fritomod/LuaEnvironment";
    require "fritomod/Metatables";
end;

LuaEnvironment.Loaders={};
local loaders=LuaEnvironment.Loaders;

function loaders.Filesystem()
	return function(name)
		if not lfs or not loadfile then
			return;
		end;
		name = tostring(name);
		local file=name;
		if not file:find("\\.lua$") then
			file=name..".lua";
		end;
		if not lfs.attributes(file) then
			-- The file was not accessible, so just return.
			return;
		end;
		local runner, err=loadfile(file);
		if runner then
			return runner;
		end;
		return nil, err;
	end;
end;

function loaders.Ignore(...)
	local ignored;
	if select("#", ...) == 0 then
		ignored = {};
		Metatables.Default(ignored, true);
	elseif select("#", ...) > 1
	or type(...) ~= "table" then
		ignored = {};
		for i=1, select("#", ...) do
			ignored[select(i, ...)] = true;
		end;
	else
		assert(select("#", ...) == 1);
		assert(type(...) == "table");
		if #(...) > 0 then
			for _, name in ipairs(...) do
				ignored[name] = true;
			end;
		else
				ignored = ...;
		end;
	end;
	assert(ignored, "Ignored was not provided");
	return function(package)
		if ignored[package] then
			return Noop;
		end;
	end;
end;

-- vim: set noet :

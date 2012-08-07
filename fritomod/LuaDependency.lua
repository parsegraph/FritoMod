if nil ~= require then
    require "fritomod/OOP-Class";
    require "fritomod/LuaEnvironment";
end;

LuaDependency = OOP.Class();

function LuaDependency:NewEnvironment(file)
	return LuaEnvironment:New(pristine);
end;

function LuaDependency:DependsOn(child, parent)
	-- Noop; overriddable
end;

-- Ignore any files that do not pass the specified
-- filter. Implementations do not need to save this list;
-- it's up to the client to apply this filter at
-- appropriate times.
function LuaDependency:Filter(filter, ...)
    -- Noop; overriddable
end;

function LuaDependency:Process(file)
	local env = self:NewEnvironment(file);
	env:AddLoader(LuaEnvironment.Loaders.Ignore("bit", "lfs"));
	env:AddLoader(LuaEnvironment.Loaders.Filesystem(loadfile));
	env:Require("bin/global");

	local dependencyStack = {};

	local function CleanName(package)
		if not package:find("\.lua$") then
			package=package..".lua";
		end;
		return package;
	end;

    local dep = self;

	-- Register our listeners to construct our dependency tree.
	function env:OnRequireLoading(package)
		package = CleanName(package);
		if #dependencyStack > 0 then
			-- We have entries in our stack, so we can start
			-- adding dependencies. Otherwise, we wouldn't
			-- know the parent.
			local child=dependencyStack[#dependencyStack]
			dep:DependsOn(child, package);
		end;
		table.insert(dependencyStack, package);
	end;

	function env:OnRequireFinish(package)
		package = CleanName(package);
		local expected=table.remove(dependencyStack);
		assert(package==expected, "Unexpected dependency. Expected: "..expected.." Received: "..package);
	end;

	env:Require(file);
end;

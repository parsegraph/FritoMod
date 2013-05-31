if nil ~= require then
    require "fritomod/OOP-Class";
    require "fritomod/LuaEnvironment";
    require "fritomod/LuaEnvironment-Loaders";
end;

LuaDependency = OOP.Class();

function LuaDependency:NewEnvironment(file)
	return LuaEnvironment:New();
end;

function LuaDependency:DependsOn(child, parent)
	-- Noop; overriddable
end;

-- Ignore any files that do not pass the specified
-- filter. Implementations do not need to save this list;
-- it's up to the client to apply this filter at
-- appropriate times.
function LuaDependency:SetFilter(filter, ...)
    self.filter = Curry(filter, ...);
end;

function LuaDependency:Process(file)
	local env = self:NewEnvironment(file);
	env:AddLoader(LuaEnvironment.Loaders.Ignore("bit", "lfs"));
	env:AddLoader(LuaEnvironment.Loaders.Filesystem());

	local dependencyStack = {};

	local function CleanName(package)
		if not package:find("\.lua$") then
			package=package..".lua";
		end;
		package = package:gsub("\\", "/");
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

	function env:OnRequireLoaded(package)
		package = CleanName(package);
		local expected=table.remove(dependencyStack);
		assert(package==expected, "Unexpected dependency. Expected: "..expected.." Received: "..package);
	end;

	env:Require("bin/global");
	env:Require(file);
end;

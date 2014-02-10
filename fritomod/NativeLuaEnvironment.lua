-- Represents a thin LuaEnvironment that wraps a table (typically _G).
--
-- These fake LuaEnvironments behave as final parents in a LuaEnvironment
-- hierarchy. You probably won't need to ever directly use this; just use
-- the constructor for a LuaEnvironment if you want a raw table to act as
-- the final parent.

if nil ~= require then
    require "fritomod/OOP-Class";
end;

NativeLuaEnvironment = OOP.Class("NativeLuaEnvironment");

function NativeLuaEnvironment:Constructor(globals, usePackageLoaded)
    self.globals = globals;
    if usePackageLoaded == nil then
        usePackageLoaded = true;
    end;
    self.usePackageLoaded = usePackageLoaded;
end;

function NativeLuaEnvironment:Get(name)
    return self.globals[name];
end;

function NativeLuaEnvironment:Set(name, value)
    self.globals[name] = value;
end;

function NativeLuaEnvironment:LoadModule(name)
    error("No loader found for module: " .. name);
end;

function NativeLuaEnvironment:IsLoaded(name)
    return self.usePackageLoaded and package.loaded[name] ~= nil;
end;

-- vim: set et :

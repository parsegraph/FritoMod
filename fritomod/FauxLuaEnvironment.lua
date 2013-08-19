-- Represents a thin LuaEnvironment that wraps a table (typically _G).
--
-- These fake LuaEnvironments behave as final parents in a LuaEnvironment
-- hierarchy. You probably won't need to ever directly use this; just use
-- the constructor for a LuaEnvironment if you want a raw table to act as
-- the final parent.

if nil ~= require then
    require "fritomod/OOP-Class";
end;

FauxLuaEnvironment = OOP.Class("FauxLuaEnvironment");

function FauxLuaEnvironment:Constructor(globals)
    self.globals = globals;
end;

function FauxLuaEnvironment:Get(name)
    return self.globals[name];
end;

function FauxLuaEnvironment:Set(name, value)
    self.globals[name] = value;
end;

function FauxLuaEnvironment:LoadModule(name)
    error("No loader found for module: " .. name);
end;

function FauxLuaEnvironment:IsLoaded(name)
    return false;
end;

-- vim: set et :

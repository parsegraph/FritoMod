if nil ~= require then
    require "fritomod/currying";
    require "fritomod/LuaEnvironment";
    require "fritomod/OOP";
    require "hack/Assets";
end;

Hack = Hack or {};
Hack.Connectors = Hack.Connectors or {};
local Connectors = Hack.Connectors;
local Assets = Hack.Assets;

function Connectors.Global(name, asset, ...)
    asset = Assets.AsAsset(asset, ...);
    return function(env)
        return env:Change(name, asset(env, "AddDestructor"));
    end;
end;

function Connectors.Lazy(name, asset, ...)
    asset = Assets.AsAsset(asset, ...);
    return function(env)
        return env:Lazy(name, Seal(asset, env, "AddDestructor"));
    end;
end;

function Connectors.Proxy(name, asset, ...)
    asset = Assets.AsAsset(asset, ...);
    return function(env)
        return env:Proxy(name, Seal(asset, env, "AddDestructor"));
    end;
end;

function Connectors.Use(name, func, ...)
    func = Curry(func, ...);
    return function(env)
        return func(env, env, "AddDestructor");
    end;
end;

function Connectors.Member(klassName, name, asset, ...)
    asset = Assets.AsAsset(asset, ...);
    return function(env)
        local klass;
        for i, namePart in ipairs(Strings.Split("%.", klassName)) do
            if klass == nil then
                klass = env:Get(namePart);
            else
                klass = klass[namePart];
            end;
            assert(klass, string.format(
                "Failed to find table with name '%s' (index: %d) within %s",
                namePart, i, klassName));
        end;
        assert(OOP.IsClass(klass),
            ("klass at %s is not a class"):format(klassName));
        klass:AddConstructor(function(self)
            self[name] = asset(self, "AddDestructor");
        end);
    end;
end;

-- vim: set et :

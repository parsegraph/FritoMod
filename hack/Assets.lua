if nil ~= require then
    require "fritomod/currying";
    require "fritomod/Tests";
    require "fritomod/Frames";
    require "fritomod/basic";
end;

Hack = Hack or {};
Hack.Assets = Hack.Assets or {};
local Assets = Hack.Assets;

function Assets.AsAsset(asset, ...)
    if select("#", ...) == 0 and not IsCallable(asset) then
        return Curry(asset, "Make");
    end;
    return Curry(asset, ...);
end;

function Assets.Constant(value)
    return function()
        return value;
    end;
end;

function Assets.Factory(asset, ...)
    asset = Assets.AsAsset(asset, ...);
    return function(dtor, ...)
        dtor = Curry(dtor, ...);
        return function()
            return asset(dtor);
        end;
    end;
end;

function Assets.Flag()
    return function(dtor, ...)
        dtor = Curry(dtor, ...);
        local flag = Tests.Flag();
        dtor(flag.Lower);
        return flag;
    end;
end;

function Assets.Singleton(asset, ...)
    asset = Assets.AsAsset(asset, ...);
    local singleton;
    return function(dtor, ...)
        dtor = Curry(dtor, ...);
        if singleton == nil then
            singleton = asset(dtor);
            dtor(function()
                -- Clear the singleton since it's been destroyed.
                singleton = nil;
            end);
        end;
        return singleton;
    end;
end;

function Assets.Undoer()
    return function(dtor, ...)
        dtor = Curry(dtor, ...);
        return function(...)
            if select("#", ...) > 1 or IsCallable(...) then
                return dtor(...);
            end;
            local obj = ...;
            if not obj or type(obj) ~= "table" then
                return;
            end;
            if IsCallable(obj.Destroy) then
                return dtor(obj, "Destroy");
            end;
            if Frames.AsRegion(obj) then
                return dtor(Frames.Destroy, obj);
            end;
            -- Nothing we could destroy, so just return
        end;
    end;
end;

-- vim: set et :

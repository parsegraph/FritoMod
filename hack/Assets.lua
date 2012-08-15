if nil ~= require then
    require "fritomod/currying";
    require "fritomod/Tests";
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

-- vim: set et :

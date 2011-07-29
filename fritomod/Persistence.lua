if nil~=require then
    require "fritomod/currying";
    require "fritomod/Functions";
    require "fritomod/Lists";
    require "fritomod/Events";
end;

local function AssertPersistence()
        assert(_Persistence~=nil, "SavedVariables have not yet been loaded");
end;

local loaded;
Persistence=setmetatable({}, {
    __index=function(self, key)
        if key=="Loaded" then
            return function()
                return loaded;
            end;
        end;
        AssertPersistence();
        return _Persistence[key];
    end,

    __newindex=function(self, key, value)
        -- TODO: This doesn't need to assert persistence; we could override these
        -- values on load.
        AssertPersistence();
        _Persistence[key]=value;
    end
});

local listeners={};
local removers;

Callbacks=Callbacks or {};
function Callbacks.Persistence(func, ...)
    func=Curry(func, ...);
    if loaded then
        Callbacks.Later(function()
            local r=func();
            if r then
                table.insert(removers, r);
            end;
        end);
    end;
    return Lists.Insert(listeners, func);
end;

function Callbacks.PersistentValue(key, func, ...)
    func=Curry(func, ...);
    return Callbacks.Persistence(function()
        local remover=func(Persistence[key]);
        if remover then
            return function()
                local newValue=remover(Persistence[key]);
                if newValue~=nil then
                    Persistence[key]=newValue;
                end;
            end;
        end;
    end);
end;

Events.ADDON_LOADED(function(addon)
    if addon~="FritoMod" then
        return;
    end;
    loaded=true;
    _Persistence=_Persistence or {};
    removers=Lists.MapCall(listeners);
end);

Events.PLAYER_LOGOUT(function(addon)
    Lists.CallEach(removers);
end);

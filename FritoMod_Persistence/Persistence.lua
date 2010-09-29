if nil~=require then
    require "FritoMod_Functional/currying";
    require "FritoMod_Functional/Functions";
    require "FritoMod_Functional/Callbacks";
    require "FritoMod_Collections/Lists";
    require "FritoMod_Events/Events";
end;

local function AssertPersistence()
        assert(_Persistence~=nil, "SavedVariables have not yet been loaded");
end;

Persistence=setmetatable({}, {
    __index=function(self, key)
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
Callbacks.Persistence=Curry(Lists.InsertFunction, listeners);

Events.ADDON_LOADED(function(addon)
    if addon=="FritoMod_Persistence" then
        _Persistence=_Persistence or {};
    end;
    removers=Lists.MapCall(listeners);
end);

Events.PLAYER_LOGOUT(Lists.CallEach, removers);

if nil~=require then
    require "FritoMod_Functional/currying";
    require "FritoMod_Functional/Functions";
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
        AssertPersistence();
        _Persistence[key]=value;
    end
});

function Functions.Persistent(func, ...)
    func=Curry(func, ...);
    return function(...)
        AssertPersistence();
        return func(...);
    end;
end;

Events.ADDON_LOADED(function(addon)
    if addon=="FritoMod_Persistence" then
        _Persistence=_Persistence or {};
    end;
end);

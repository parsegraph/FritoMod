if nil~=require then
	require "fritomod/currying";
	require "fritomod/Functions";
	require "fritomod/Lists";
	require "fritomod/Events";
	require "fritomod/Callbacks-Timing";
end;

Persistence = {};

local loaded;
local loaders={};
local savers;

local persisted;

function Persistence.Loaded()
    return loaded;
end;

local function AssertPersistence()
    assert(Persistence.Loaded(), "Persisted values are not yet available");
end;

function Persistence.RawData()
    AssertPersistence();
    return persisted;
end;

function Persistence.Load(sourceData)
    assert(not Persistence.Loaded(), "Persisted values must not be reloaded");
    assert(sourceData, "Source data must not be falsy");
	loaded=true;
    persisted=sourceData;
    trace("Firing persistence loaders");
	savers=Lists.MapCall(loaders, persisted);
end;

function Persistence.Save()
    if savers then
        trace("Firing persistence savers");
        Lists.CallEach(savers);
    end;
end;

setmetatable(Persistence, {
	__index=function(self, key)
		AssertPersistence();
		return persisted[key];
	end,

	__newindex=function(self, key, value)
		-- TODO: This doesn't need to assert persistence; we could override these
		-- values on load.
		AssertPersistence();
		persisted[key]=value;
	end
});

Callbacks=Callbacks or {};
function Callbacks.Persistence(func, ...)
	func=Curry(func, ...);
	if loaded then
		Callbacks.Later(function()
			local saver=func();
			if saver then
				table.insert(savers, saver);
			end;
		end);
	end;
	return Lists.Insert(loaders, func);
end;
Callbacks.Persist = Callbacks.Persistence;
Callbacks.Persistance = Callbacks.Persistence;
Callbacks.Peristence = Callbacks.Persistence;

function Callbacks.PersistentValue(key, func, ...)
	func=Curry(func, ...);
	return Callbacks.Persistence(function()
		local saver=func(Persistence[key]);
		if saver then
			return function()
				local newValue=saver(Persistence[key]);
				if newValue~=nil then
					Persistence[key]=newValue;
				end;
			end;
		end;
	end);
end;
Callbacks.PersistantValue = Callbacks.PersistentValue;
Callbacks.PersistValue = Callbacks.PersistentValue;
Callbacks.PeristValue = Callbacks.PersistentValue;

Events.ADDON_LOADED(function(addon)
	if addon:lower() ~= "fritomod" then
		return;
	end;
    _Persistence = _Persistence or {};
    Persistence.Load(_Persistence);
end);

Events.PLAYER_LOGOUT(Persistence.Save);

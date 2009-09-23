API.Events = {};
local Events = API.Events;

local updateListeners = {};
local eventListeners = {};

-- Populates a table with curried functions. The returned function will accept
-- a function or method, curry it and add it to the specified table. It will also
-- return a method that, when invoked, will remove the curried function from the
-- specified table.
--
-- populatedTable
--     the table that is populated
-- returns
--     a function that behaves as described above
local function FunctionPopulator(populatedTable)
    return function(listener, ...)
        listener = Curry(listener, ...);
        table.insert(populatedTable, listener);
        return Curry(Lists.RemoveAll, populatedTable, listener);
    end;
end;

Events.AddUpdateListener = FunctionPopulator(updateListeners);
Events.AddEventListener = FunctionPopulator(eventListeners);

local masterFrame = CreateFrame("Frame", nil, UIParent);
masterFrame:SetScript("OnUpdate", function(frame, elapsed) 
   Lists.MapCall(updateListeners, elapsed);
end);
masterFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
masterFrame:SetScript("OnEvent", Curry(Lists.MapCall, eventListeners));

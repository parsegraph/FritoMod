if nil ~= require then
    require "WoW_UI/Frame-Layout";

    require "FritoMod_Functional/Callbacks";
    require "FritoMod_Persistence/Persistence";

    require "FritoMod_UI/PersistentAnchor";
    require "FritoMod_UI/Anchors";
end;

-- This is the name of the table we save in Persistence
local savedKey="FritoMod.Anchors";

-- A mapping of anchor names to PersistentAnchor objects.
local anchors={};

-- The parent for every anchor created using this process.
local anchorFrame;
anchorFrame=CreateFrame("Frame", nil, UIParent);
anchorFrame:SetAllPoints();
anchorFrame:SetFrameStrata("HIGH");

function Anchors.Named(name)
    if not anchors[name] then
        anchors[name]=PersistentAnchor:New(anchorFrame);
    end;
    return anchors[name].frame;
end;
Anchors.Saved=Anchors.Named;
Anchors.Save=Anchors.Named;
Anchors.Name=Anchors.Named;
Anchors.Persistent=Anchors.Named;
Anchors.Persistant=Anchors.Named;
Anchors.Persisting=Anchors.Named;
Anchors.Persisted=Anchors.Named;
Anchors.Persist=Anchors.Named;

Anchors.Hide=Curry(Lists.Each, anchors, "Hide");
Anchors.Lock=Anchors.Hide;
Anchors.Show=Curry(Lists.Each, anchors, "Show");
Anchors.Unlock=Anchors.Show;

local showing=false;
function Anchors.Toggle()
    if showing then
        Anchors.Hide();
    else
        Anchors.Show();
    end;
    showing=not showing;
end;

Callbacks.Persistence(function()
    if Persistence[savedKey] then
        for name,a in pairs(anchors) do
            if a.frame:GetNumPoints() > 0 then
                -- Clear this entry to prevent it from being loaded, since we've had an 
                -- update since the last save.
                Persistence[savedKey][name]=nil;
            else
                a.frame:SetPoint("center");
            end;
        end;
        for name,location in pairs(Persistence[savedKey]) do
            local a=Anchors.Named(name);
            if type(location)=="string" then
                print(("Saving error found while loading %s: %s"):format(name, location));
            else
                local rv, err=pcall(a.Load, a, location);
                if not rv then
                    -- This works for now, but it'd be nice if we could be more obvious
                    -- when this stuff fails.
                    print(("Error while loading %s: %s"):format(name, err));
                end;
            end;
        end;
    else
        for name,a in pairs(anchors) do
            if a.frame:GetNumPoints() == 0 then
                a.frame:SetPoint("center");
            end;
        end;
    end;
    return function()
        for name,a in pairs(anchors) do
            Persistence[savedKey]=Persistence[savedKey] or {};
            local _, location=pcall(a.Load, a, location);
            -- This will work whether the location is a table or a error message, since
            -- we check for this during the loading process.
            Persistence[savedKey][name]=location;
        end;
    end;
end);

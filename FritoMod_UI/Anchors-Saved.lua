if nil ~= require then
    require "WoW_UI/Frame-Layout";
    require "WoW_UI/FontString";

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
        anchors[name].frame:SetPoint("center");
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

Anchors.Hide=Curry(Tables.EachValue, anchors, "Hide");
Anchors.Lock=Anchors.Hide;
Anchors.Show=Curry(Tables.EachValue, anchors, "Show");
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

local function CheckForError(name, location)
    if location and type(location)=="table" and location.error then
        print(("Save error found during loading %s: %s"):format(name, err));
        location.error=nil;
    end;
end;

Callbacks.Persistence(function()
    if Persistence[savedKey] then
        for name,a in pairs(anchors) do
            if a.frame:GetNumPoints() > 0 then
                -- Clear this entry to prevent it from being loaded, since we've had an 
                -- update since the last save.
                CheckForError(name, Persistence[savedKey][name]);
                Persistence[savedKey][name]=nil;
            else
                a.frame:SetPoint("center");
            end;
        end;
        for name,location in pairs(Persistence[savedKey]) do
            CheckForError(name, location);
            if not anchors[name] then
                -- This sets anchors[name] to a new PersistentAnchor, as needed.
                Anchors.Named(name);
            end;
            local a=anchors[name];
            local rv, err=pcall(a.Load, a, location);
            if not rv then
                -- This works for now, but it'd be nice if we could be more obvious
                -- when this stuff fails.
                print(("Error while loading %s: %s"):format(name, err));
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
            local rv, location=pcall(a.Save, a);
            if rv then
                Persistence[savedKey][name]=location;
            elseif Persistence[savedKey][name] then
                -- Keep the old one, and save the error.
                Persistence[savedKey][name].error=location;
            else
                -- Couldn't keep the old one, so make a fake one.
                Persistence[savedKey][name]={anchor="center", error=location};
            end;
        end;
    end;
end);

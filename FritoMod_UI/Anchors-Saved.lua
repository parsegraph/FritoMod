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
Anchors.anchors=anchors;

-- anchorFrame is the parent for every anchor we create here.
local anchorFrame;
anchorFrame=CreateFrame("Frame", nil, UIParent);
anchorFrame:SetAllPoints();
anchorFrame:SetFrameStrata("HIGH");

local anchorNameFrame=anchorFrame:CreateFontString();
anchorNameFrame:SetFont("Fonts\\FRIZQT__.TTF", 11);

local removers={};
local showing=false;
local function ShowAnchor(name, anchor)
    if not showing then
        return;
    end;
    Lists.InsertAll(removers, 
        anchor:Show(),
        Callbacks.EnterFrame(anchor.frame, function()
            if not anchor.frame:IsDragging() then
                anchorNameFrame:Show();
                anchorNameFrame:ClearAllPoints();
                Anchors.Over(anchorNameFrame, anchor.frame, "top", 4);
                anchorNameFrame:SetText(name);
            end;
            return Curry(anchorNameFrame, "Hide");
        end),
        Callbacks.DragFrame(anchor.frame, function()
            anchorNameFrame:Hide();
            return Curry(anchorNameFrame, "Show");
        end),
        Callbacks.Click(anchor.frame, function(b)
            if b~="MiddleButton" then
                return;
            end;
            if Persistence[savedKey] then
                Persistence[savedKey][name]=nil;
            end;
            anchors[name]:Hide();
            anchors[name]=nil;
        end)
    );
end;

function Anchors.Named(name)
    local anchor;
    if anchors[name] then
        anchor=anchors[name];
    else
        anchor=PersistentAnchor:New(anchorFrame);
        anchor.frame:SetPoint("center");
        anchors[name]=anchor;
        ShowAnchor(name, anchor)
    end;
    return anchor.frame;
end;
Anchors.Saved=Anchors.Named;
Anchors.Save=Anchors.Named;
Anchors.Name=Anchors.Named;
Anchors.Persistent=Anchors.Named;
Anchors.Persistant=Anchors.Named;
Anchors.Persisting=Anchors.Named;
Anchors.Persisted=Anchors.Named;
Anchors.Persist=Anchors.Named;

do
    function Anchors.Show()
        if showing then
            return;
        end;
        showing=true;
        Tables.EachPair(anchors, ShowAnchor);
        return Anchors.Hide;
    end;
    Anchors.Unlock=Anchors.Show;

    function Anchors.Hide()
        if not showing then
            return;
        end;
        showing=false;
        Lists.CallEach(removers);
    end;
    Anchors.Lock=Anchors.Hide;

    function Anchors.Toggle()
        if showing then
            Anchors.Hide();
        else
            Anchors.Show();
        end;
    end;
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

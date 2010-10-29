if nil ~= require then
    require "wow/Frame-Layout";

    require "Serializers";
    require "Persistence";
    require "Frames";
end;

-- This is the name of the table we save in Persistence
local PERSISTENCE_KEY="FritoMod.PersistentFrames"

local positionedFrames={};

local function LoadPoint(name, frame, savedPosition)
    if not savedPosition then
        frame:SetPoint("center");
    end;
    if type(savedPosition)=="table" and savedPosition.error then
        print(("Save error found during loading %s: %s"):format(name, savedPosition.error));
        savedPosition.error=nil;
    end;
    if frame:GetNumPoints()==0 then
        local rv, err=pcall(Serializers.LoadPoint, savedPosition, frame);
        if not rv then
            -- This works for now, but it'd be nice if we could be more obvious
            -- when this stuff fails.
            print(("Error while loading %s: %s"):format(name, err));
        end;
    end;
end;

function Frames.Position(frame, name)
    positionedFrames[name]=frame;
    if frame and Persistence.Loaded() then
        local savedPosition;
        if Persistence[PERSISTENCE_KEY] then
            savedPosition=Persistence[PERSISTENCE_KEY][name];
        end;
        LoadPoint(name, frame, savedPosition);
    end;
    return Functions.OnlyOnce(function()
        positionedFrames[name]=nil;
    end);
end;

Callbacks.PersistentValue(PERSISTENCE_KEY, function(persistedFrames)
    if persistedFrames then
        -- Load the persisted value, if available, for any positioned frame.
        for name,frame in pairs(positionedFrames) do
            LoadPoint(name, frame, persistedFrames[name]);
        end;
    else
        -- Set all positioned frames to defaults.
        for name,frame in pairs(positionedFrames) do
            if frame:GetNumPoints()==0 then
                frame:SetPoint("center");
            end;
        end;
    end;
    return function(persistedFrames)
        if not #positionedFrames then
            return;
        end;
        persistedFrames=persistedFrames or {};
        for name,frame in pairs(positionedFrames) do
            local rv, savedPosition=pcall(Serializers.SavePoint, frame, 1);
            if rv then
                persistedFrames[name]=savedPosition;
            elseif persistedFrames[name] then
                -- Keep the old one, and save the error.
                persistedFrames[name].error=savedPosition;
            else
                -- Couldn't keep the old one, so make a fake one.
                persistedFrames[name]={anchor="center", error=savedPosition};
            end;
        end;
        return persistedFrames;
    end;
end);

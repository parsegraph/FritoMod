if nil ~= require then
	require "wow/Frame-Layout";

	require "fritomod/Serializers-Point";
	require "fritomod/Persistence";
	require "fritomod/Frames";
end;

-- This is the name of the table we save in Persistence
local PERSISTENCE_KEY="FritoMod.PersistentFrames"

local positionedFrames={};
local defaultPositions = {};

local function LoadPoint(name, frame, savedPosition, defaultPosition)
	if not savedPosition then
		trace("No saved position; using default for %q", name);
        if defaultPosition then
            defaultPosition(frame);
        else
            frame:SetPoint("center");
        end;
	end;
	if type(savedPosition)=="table" and savedPosition.error then
		print(("Save error found during loading %s: %s"):format(name, savedPosition.error));
		savedPosition.error=nil;
	end;
	if frame:GetNumPoints()==0 then
		local rv, err=pcall(Serializers.LoadAllPoints, savedPosition, frame);
		if not rv then
			-- This works for now, but it'd be nice if we could be more obvious
			-- when this stuff fails.
			print(("Error while loading %s: %s"):format(name, err));
		end;
	end;
end;

function Frames.Position(frame, ...)
	frame=Frames.AsRegion(frame);
    local name, defaultPosition;

    if select("#", ...) == 1 then
        if IsCallable(...) then
            defaultPosition = ...;
        else
            name = ...;
        end;
    elseif select("#", ...) > 1 then
        local first = ...;
        if IsCallable(first) then
            defaultPosition = Curry(...);
            name = nil;
        else
            name = first;
            defaultPosition = Curry(select(2, ...));
        end;
    end;
    name = name or frame:GetName();
	positionedFrames[name]=frame;
	if frame and Persistence.Loaded() then
		local savedPosition;
		if Persistence[PERSISTENCE_KEY] then
			savedPosition=Persistence[PERSISTENCE_KEY][name];
		end;
		LoadPoint(name, frame, savedPosition, defaultPosition);
    elseif defaultPosition then
        defaultPositions[name] = defaultPosition;
	end;
	return Functions.OnlyOnce(function()
		positionedFrames[name]=nil;
	end);
end;

function Frames.DumpPosition(name)
	if Persistence.Loaded() and Persistence[PERSISTENCE_KEY] then
		return Persistence[PERSISTENCE_KEY][name];
	end;
end;

local function Upgrade(persistedFrames)
    if persistedFrames.__version == nil then
        local upgraded = {
            __version = 2
        };
        for name, position in pairs(persistedFrames) do
            if name ~= "__version" then
                -- Convert single points to lists of points.
                upgraded[name] = {position};
            end;
        end;
        return upgraded;
    else
        return persistedFrames;
    end;
end;

Callbacks.PersistentValue(PERSISTENCE_KEY, function(persistedFrames)
	if persistedFrames then
        persistedFrames = Upgrade(persistedFrames);
        Persistence[PERSISTENCE_KEY] = persistedFrames;

		-- Load the persisted value, if available, for any positioned frame.
		for name,frame in pairs(positionedFrames) do
			LoadPoint(name, frame, persistedFrames[name], defaultPositions[name]);
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
			local rv, savedPosition=pcall(Serializers.SaveAllPoints, frame, 1);
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

if nil ~= require then
	require "fritomod/Metatables";
	require "fritomod/OOP-Class";
	require "fritomod/Lists"
	require "fritomod/Tables";
	require "fritomod/ListenerList";
	require "fritomod/Mixins-Log";

	require "wow/World";
end;

WoW=WoW or Metatables.Defensive();
WoW.Frame=OOP.Class("Frame", Mixins.Log);
local Frame=WoW.Frame;

Frame:AddDestructor(function(self)
    self:ClearAllPoints();
    self:Hide();
end);

function Frame:GetName()
    return nil;
end;

function WoW.AssertFrame(frame, reason)
    if reason then
        reason = ". Reason: " .. reason;
    end;
	assert(frame, "Frame must not be falsy" .. reason);
    assert(type(frame) == "table", "Provided argument is not a frame, but was "..type(frame)..reason);
    assert(
        OOP.InstanceOf(WoW.Frame, frame),
        "Provided argument is not a frame, but was "..tostring(frame)..reason
    );
end;

do
	local frameTypes = {};

	function WoW.RegisterFrameType(name, klass)
		name = tostring(name):lower();
		frameTypes[name] = klass;
	end;

	function WoW.GetFrameType(name)
		name = tostring(name):lower();
		return frameTypes[name];
	end;

	function WoW.GetNameForType(klass)
        return Tables.KeyFor(frameTypes, klass);
    end;

	function WoW.NewFrame(name, ...)
		name = tostring(name):lower();
		local klass = frameTypes[name];
		assert(klass, "No creator for frametype: "..name);
        return klass:New(...);
	end;
end;

function Frame:GetObjectType()
	return WoW.GetNameForType(self.class);
end;

if not WoW.GetFrameType("Frame") then
    WoW.RegisterFrameType("Frame", WoW.Frame);
end;

if WoW.CreateUIParent == nil then
    function WoW.CreateUIParent()
        return WoW.Frame:New();
    end;
end;

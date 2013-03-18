if nil ~= require then
	require "fritomod/Metatables";
	require "fritomod/OOP-Class";
	require "fritomod/Lists"

	require "wow/World";
end;

WoW=WoW or Metatables.Defensive();
WoW.Frame=OOP.Class();
local Frame=WoW.Frame;

function WoW.AssertFrame(frame)
	assert(frame, "Frame must not be falsy");
	assert(
		OOP.InstanceOf(WoW.Frame, frame),
		"Provided argument is not a frame. Given: "..type(frame)
	);
end;

do
	local frameTypes = {};
    local frameDelegates = {};
    local frameInheritance = {};

    local function InstallDelegates(name, frame, installedDelegates)
        local delegateCreators = frameDelegates[name];
        if delegateCreators then
            installedDelegates = installedDelegates or {};
            for category, delegateCreator in pairs(delegateCreators) do
                if not installedDelegates[category] then
                    installedDelegates[category] = true;
                    frame:SetDelegate(category, delegateCreator(frame));
                end;
            end;
        end;
        if frameInheritance[name] then
            InstallDelegates(frameInheritance[name], frame, installedDelegates);
        end;
    end;

	function WoW.RegisterFrameType(name, klass)
		name = tostring(name):lower();
		frameTypes[name] = klass;

        klass:AddConstructor(function(frame)
            frame.delegates = {};
            InstallDelegates(name, frame);
        end);
	end;

    function WoW.RegisterFrameInheritance(name, parent)
        name = tostring(name):lower();
        parent = tostring(parent):lower();
        frameInheritance[name] = parent;
    end;

    function WoW.SetFrameDelegate(name, category, delegateCreator, ...)
        name = tostring(name):lower();
        frameDelegates[name] = frameDelegates[name] or {};
        frameDelegates[name][category] = Curry(delegateCreator, ...);
    end;

	function WoW.NewFrame(name, ...)
		name = tostring(name):lower();
		local klass = frameTypes[name];
		assert(klass, "No creator for frametype: "..name);
        return klass:New(...);
	end;
end;

WoW.RegisterFrameType("Frame", WoW.Frame, "New");

function Frame:GetObjectType()
	return "Frame";
end;

function Frame:GetDelegate(category)
    return self.delegates[category];
end;
Frame.delegate = Frame.GetDelegate;

function Frame:SetDelegate(category, obj)
    self.delegates[category] = obj;
end;

function WoW.Delegate(klass, category, name)
    if type(name) == "table" and #name > 0 then
        for i=1, #name do
            WoW.Delegate(klass, category, name[i]);
        end;
        return;
    end;
    klass[name] = function(self, ...)
        local delegate = self:GetDelegate(category);
        assert(delegate, "No delegate defined for category: " .. category);
        return delegate[name](delegate, ...);
    end;
end;

if nil ~= require then
	require "fritomod/Metatables";
	require "fritomod/OOP-Class";
	require "fritomod/Lists"
	require "fritomod/ListenerList";

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
    local frameDelegates = {};
    local frameInheritance = {};

    local delegateOrdering = {};

    local function InstallDelegates(name, frame, installedDelegates)
        local delegateCreators = frameDelegates[name];
        if delegateCreators then
            installedDelegates = installedDelegates or {};
            local delegateOrder = delegateOrdering[name];
            for _, category in ipairs(delegateOrder) do
                local delegateCreator = delegateCreators[category];
                if not installedDelegates[category] then
                    installedDelegates[category] = true;
                    frame:SetDelegate(category, delegateCreator:New(frame));
                end;
            end;
        end;
        if frameInheritance[name] then
            InstallDelegates(frameInheritance[name], frame, installedDelegates);
        elseif name ~= "frame" then
            InstallDelegates("frame", frame, installedDelegates);
        end;
    end;

	function WoW.RegisterFrameType(name, klass)
		name = tostring(name):lower();
		frameTypes[name] = klass;

        klass:AddConstructor(function(frame)
            frame.delegates = {};
            frame.delegateListeners = ListenerList:New();
            InstallDelegates(name, frame);
        end);
	end;

    function WoW.RegisterFrameInheritance(name, parent)
        name = tostring(name):lower();
        parent = tostring(parent):lower();
        if parent ~= "frame" then
            frameInheritance[name] = parent;
        end;
    end;

    function WoW.SetFrameDelegate(name, category, delegate)
        name = tostring(name):lower();
        if not frameDelegates[name] then
            frameDelegates[name] = {};
            delegateOrdering[name] = {};
        end;
        frameDelegates[name][category] = delegate;
        table.insert(delegateOrdering[name], category);
    end;

    function WoW.GetFrameDelegate(name, category)
        name = tostring(name):lower();
        return frameDelegates[name] and frameDelegates[name][category];
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

function Frame:SetDelegate(category, delegate)
    self.delegates[category] = delegate;
    self.delegateListeners:Fire(category, delegate);
end;

function Frame:OnDelegateSet(func, ...)
    return self.delegateListeners:Add(func, ...);
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
        assert(delegate,
            "No delegate defined for category: " .. category .. " so the '" .. name .. "' method cannot be invoked"
        );
        local delegateFunc = delegate[name];
        assert(delegateFunc, "Delegate must implement the method '" .. name .. "'");
        return delegateFunc(delegate, ...);
    end;
end;

if WoW.CreateUIParent == nil then
    function WoW.CreateUIParent()
        return WoW.Frame:New();
    end;
end;

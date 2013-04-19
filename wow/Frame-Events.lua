if nil ~= require then
	require "wow/Frame";

	require "fritomod/basic";
	require "fritomod/Lists";
	require "fritomod/OOP-Class";
end;

local Frame = WoW.Frame;

WoW.Delegate(Frame, "event", {
    "HasScript",
    "SetScript",
    "GetScript",
    "HookScript",
    "FireEvent",

    "RegisterEvent",
    "RegisterAllEvents",
    "UnregisterEvent",
    "IsEventRegistered"
});

local Delegate = OOP.Class();

if not WoW.GetFrameDelegate("Frame", "event") then
	WoW.SetFrameDelegate("Frame", "event", Delegate, "New");
end;

function Delegate:Constructor(frame)
    self.frame = frame;
    self.eventHandlers = {};
end;

function Delegate:GetHandlers(event)
	if not self:HasScript(event) then
		return;
	end;
	local handlers=self.eventHandlers[event];
	if not handlers then
		handlers={
			hooks={}
		};
		self.eventHandlers[event]=handlers;
	end;
	return handlers;
end;

function Delegate:FireEvent(event, ...)
	local handlers=self:GetHandlers(event);
	if handlers then
		if handlers.handler then
			handlers.handler(self, event, ...);
		end;
		Lists.CallEach(handlers.hooks, self, event, ...);
	end;
end;

function Delegate:HasScript(event)
	return true;
end;

function Delegate:GetScript(event)
	local handlers=self:GetHandlers(event);
	if handlers then
		return handlers.handler;
	end;
end;

function Delegate:SetScript(event, handler)
	assert(event, "Event must not be falsy");
	assert(type(event)=="string", "Event must be a string");
	local handlers=self:GetHandlers(event);
	if handlers then
		trace("Adding event handler for %q to frame %q", event, tostring(self));
		handlers.handler=handler;
	end;
end;

function Delegate:HookScript(event, handler)
	local handlers=self:GetHandlers(event);
	if handlers then
		table.insert(handlers.hooks, handler);
	end;
end;

function Delegate:IsEventRegistered(event)
	local handlers=self:GetHandlers(event);
	return handlers and handlers.registered;
end;

function Delegate:RegisterEvent(event)
	local handlers=self:GetHandlers(event);
	if handlers then
		handlers.registered=true;
	end;
end;

function Delegate:UnregisterEvent(event)
	local handlers=self:GetHandlers(event);
	if handlers then
		handlers.registered=false;
	end;
end;

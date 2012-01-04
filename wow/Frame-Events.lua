if nil ~= require then
	require "wow/Frame";

	require "fritomod/basic";
	require "fritomod/Lists";
	require "fritomod/OOP-Class";
end;

local frameRegistry = setmetatable({}, {
	__mode = "k"
});
function WoW.FireFrameEvent(frame, ...)
	local frameEvent = frameRegistry[frame];
	assert(frameEvent, "Frame is not in registry: "..tostring(frame));
	frameEvent:FireEvent(...);
end;

local FrameEvents=OOP.Class();

WoW.Frame:AddConstructor(FrameEvents, "New");

function FrameEvents:Constructor(frame)
	self.frame = frame;
	WoW.AssertFrame(frame);
	frameRegistry[frame] = self;

	self.eventHandlers = {};

	WoW.Inject(frame, self, {
		"HasScript",
		"GetScript",
		"SetScript",
		"HookScript",
		"EnableMouse",
		"IsEventRegistered",
		"RegisterEvent",
		"UnregisterEvent",
	});
end;

function FrameEvents:HasScript(event)
	-- TODO Frame:HasScript stub
	return true;
end;

function FrameEvents:GetHandlers(event)
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

function FrameEvents:GetScript(event)
	local handlers=self:GetHandlers(event);
	if handlers then
		return handlers.handler;
	end;
end;

function FrameEvents:SetScript(event, handler)
	assert(event, "Event must not be falsy");
	assert(type(event)=="string", "Event must be a string");
	local handlers=self:GetHandlers(event);
	if handlers then
		trace("Adding event handler for %q to frame %q", event, tostring(self.frame));
		handlers.handler=handler;
	end;
end;

function FrameEvents:HookScript(event, handler)
	local handlers=self:GetHandlers(event);
	if handlers then
		table.insert(handlers.hooks, handler);
	end;
end;

function FrameEvents:FireEvent(event, ...)
	local handlers=self:GetHandlers(event);
	if handlers then
		if handlers.handler then
			handlers.handler(self, event, ...);
		end;
		Lists.CallEach(handlers.hooks, self, event, ...);
	end;
end;

function FrameEvents:EnableMouse(enabled)
	-- TODO Frame:EnableMouse stub
	-- XXX What does this function do in-game?
end;

function FrameEvents:IsEventRegistered(event)
	local handlers=self:GetHandlers(event);
	return handlers and handlers.registered;
end;

function FrameEvents:RegisterEvent(event)
	local handlers=self:GetHandlers(event);
	if handlers then
		handlers.registered=true;
	end;
end;

function FrameEvents:UnregisterEvent(event)
	local handlers=self:GetHandlers(event);
	if handlers then
		handlers.registered=false;
	end;
end;

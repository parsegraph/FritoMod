if nil ~= require then
	require "fritomod/OOP-Class";
	require "fritomod/ListenerList";
	require "fritomod/ListenerList";
end;

local MouseWheelListener = OOP.Class(ListenerList);

function MouseWheelListener:Constructor(frame)
	self.super.Constructor(self, "MouseWheel listener");
	self.frame = frame;
end;

function MouseWheelListener:Install()
	self.super.Install(self);
	frame:EnableMouseWheel(true);
	self.scriptHandler = Callbacks.Script(self.frame, "OnMouseWheel", self, "Fire");
end;

function MouseWheelListener:Uninstall()
	frame:EnableMouseWheel(false);
	if self.scriptHandler then
		self.scriptHandler();
		self.scriptHandler=nil;
	end;
	self.super.Uninstall(self);
end;

Callbacks = Callbacks or {};

local MOUSE_WHEEL_LISTENER="__MouseWheelListener";
function Callbacks.MouseWheel(frame, func, ...)
	frame = Frames.AsRegion(frame);
	assert(frame.EnableMouseWheel, "Frame must support mouse wheel events");
	func=Curry(func, ...);
	if not frame[MOUSE_WHEEL_LISTENER] then
		frame[MOUSE_WHEEL_LISTENER] = MouseWheelListener:New(frame);
	end;
	return frame[MOUSE_WHEEL_LISTENER]:Add(func);
end;

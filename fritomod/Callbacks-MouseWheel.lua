if nil ~= require then
	require "fritomod/OOP-Class";
	require "fritomod/ListenerList";
	require "fritomod/ListenerList";
end;

local MouseWheelListener = OOP.Class(ListenerList);

function MouseWheelListener:Constructor(frame)
	MouseWheelListener.super.Constructor(self, "MouseWheel listener");
	self.frame = frame;

	self:AddInstaller(frame, "EnableMouseWheel", true);
	self:AddInstaller(Callbacks.Script, self.frame, "OnMouseWheel", self, "Fire");
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

if nil ~= require then
	require "fritomod/OOP-Class";
	require "fritomod/ListenerList";
	require "fritomod/ListenerList";
end;

local KeyListener = OOP.Class(ListenerList);

function KeyListener:Constructor(frame, event)
	self.super.Constructor(self, "Key listener");
	self.frame = frame;
	self.event = event;
end;

local KEYBOARD_ENABLER = "__KeyboardEnabler";

function KeyListener:Install()
	self.super.Install(self);

	if not frame[KEYBOARD_ENABLER] then
		frame[KEYBOARD_ENABLER] = Functions.Install(
			Seal(frame, "EnableKeyboard", true),
			Noop);
	end;

	self.keyboardEnabled = frame[KEYBOARD_ENABLER]();

	self.scriptHandler = Callbacks.Script(self.frame, event, self, "Fire");
end;

function KeyListener:Uninstall()
	if self.keyboardEnabled then
		self.keyboardEnabled();
		self.keyboardEnabled=nil;
	end;
	if self.scriptHandler then
		self.scriptHandler();
		self.scriptHandler=nil;
	end;
	self.super.Uninstall(self);
end;

Callbacks = Callbacks or {};


local function KeyListener(event)
	local LISTENER_NAME = "__"..event;

	return function(frame, func, ...)
		frame = Frames.AsRegion(frame);
		assert(frame.EnableKeyboard, "Frame must support keyboard events");
		func=Curry(func, ...);
		if not frame[LISTENER_NAME] then
			frame[LISTENER_NAME] = KeyListener:New(frame, event);
		end;
		return frame[LISTENER_NAME]:Add(func);
	end;
end;

Callbacks.Char=KeyListener("OnChar");
Callbacks.KeyUp=KeyListener("OnKeyUp");
Callbacks.KeyDown=KeyListener("OnKeyDown");

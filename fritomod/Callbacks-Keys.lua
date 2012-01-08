if nil ~= require then
	require "fritomod/OOP-Class";
	require "fritomod/ListenerList";
	require "fritomod/ListenerList";
end;

local KeyListener = OOP.Class(ListenerList);

local KEYBOARD_ENABLER = "__KeyboardEnabler";

function KeyListener:Constructor(frame, event)
	self.super.Constructor(self, "Key listener");
	self.frame = frame;
	self.event = event;

	-- Enable the keyboard, if it's not already enabled.
	self:AddInstaller(function()
		if not frame[KEYBOARD_ENABLER] then
			frame[KEYBOARD_ENABLER] = Functions.Install(
				Seal(frame, "EnableKeyboard", true),
				Noop);
		end;
		return frame[KEYBOARD_ENABLER]();
	end);

	self:AddInstaller(Callbacks.Script, self.frame, event, self, "Fire");
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

function Callbacks.Key(key, func, ...)
	key=key:lower();
	func=Curry(func, ...);
	local onKeyUp;
	return Functions.OnlyOnce(Lists.CallEach, {
		Callbacks.KeyDown(function(pressedKey)
			pressedKey=pressedKey:lower();
			if pressedKey == key then
				func();
			end;
		end),
		Callbacks.KeyUp(function(pressedKey)
			if onKeyUp then
				pressedKey=pressedKey:lower();
				if pressedKey == key then
					onKeyUp();
					onKeyUp=nil;
				end;
			end
		end)
	});
end;
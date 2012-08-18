if nil ~= require then
	require "fritomod/OOP-Class";
	require "fritomod/ListenerList";
end;

Callbacks = Callbacks or {};

local function ActivateKeyboard(frame)
	local KEYBOARD_ENABLER = "__KeyboardEnabler";
	if not frame[KEYBOARD_ENABLER] then
		frame[KEYBOARD_ENABLER] = Functions.Install(
			Seal(frame, "EnableKeyboard", true),
			Noop);
	end;
	return frame[KEYBOARD_ENABLER]();
end;

local function KeyListener(event)
	return function(frame, func, ...)
		frame = Frames.AsRegion(frame);
		assert(frame.EnableKeyboard, "Frame must support keyboard events");
		local list = Frames.GetCallbackHandler(frame, event,
			ActivateKeyboard, frame);
		return list:Add(func, ...);
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

function Callbacks.Modifier(key, func, ...)
	key=key:upper();
	func=Curry(func, ...);

	local onUp;
	return Events.MODIFIER_STATE_CHANGED(function(what, isDown)
		-- I use EndsWith to allow for key to be either 'ALT' or 'LALT' without
		-- requiring any extra code.
		if not Strings.EndsWith(what, key) then
			return;
		end;
		if isDown == 1 and not onUp then
			onUp = func() or Noop;
		elseif onUp then
			onUp();
			onUp = nil;
		end;
	end);
end;

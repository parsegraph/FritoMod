if nil ~= require then
	require "fritomod/ListenerList";
end;

Callbacks = Callbacks or {};

local function ActivateKeyboard(frame)
	local KEYBOARD_ENABLER = "__KeyboardEnabler";
	if not frame[KEYBOARD_ENABLER] then
		frame[KEYBOARD_ENABLER] = Functions.Install(function()
			frame:EnableKeyboard(true);
			return Functions.OnlyOnce(frame, "EnableKeyboard", false);
		end);
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

Callbacks.KeyDown=KeyListener("OnKeyDown");
Callbacks.KeyPress=Callbacks.KeyDown;

Callbacks.KeyUp=KeyListener("OnKeyUp");
Callbacks.KeyRelease=Callbacks.KeyUp;

local modifierFor = {
	SHIFT = "SHIFT",
	LSHIFT = "SHIFT",
	RSHIFT = "SHIFT",

	CONTROL = "CONTROL",
	LCONTROL = "CONTROL",
	RCONTROL = "CONTROL",
};

function Callbacks.Keys(frame, func, ...)
	func = Curry(func, ...);
	local callbacks = {};

	return Functions.OnlyOnce(Lists.CallEach, {
		Callbacks.KeyDown(frame, function(pressedKey, ...)
			if modifierFor[pressedKey] then
				-- Refuse to handle modifiers
				return;
			end;
			if callbacks[pressedKey] then
				-- Redundant keypress, so just ignore it
				return;
			end;
			callbacks[pressedKey] = func(pressedKey, ...) or Noop;
		end),
		Callbacks.KeyUp(frame, function(pressedKey, ...)
			if callbacks[pressedKey] then
				callbacks[pressedKey](pressedKey, ...);
				callbacks[pressedKey] = nil;
			end;
		end)
	});
end;

function Callbacks.Modifiers(frame, func, ...)
	func = Curry(func, ...);
	local callbacks = {};
	local modCounts = {};

	return Functions.OnlyOnce(Lists.CallEach, {
		Callbacks.KeyPress(frame, function(key, ...)
			local mod = modifierFor[tostring(key):upper()];
			if not mod then
				return;
			end;
			if not modCounts[mod] then
				callbacks[mod] = func(mod, ...) or Noop;
				modCounts[mod] = 0;
			end;
			modCounts[mod] = modCounts[mod] + 1;
		end),
		Callbacks.KeyUp(frame, function(key, ...)
			local mod = modifierFor[tostring(key):upper()];
			if not mod then
				return;
			end;
			if not modCounts[mod] then
				return;
			end;
			modCounts[mod] = modCounts[mod] - 1;
			if modCounts[mod] > 0 then
				return;
			end;
			modCounts[mod] = nil;
			callbacks[mod](mod, ...);
			callbacks[mod] = nil;
		end)
	});
end;

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

-- vim: set noet :

-- Callbacks that deal with UI events, like clicking and key presses.
--
-- These callbacks follow this general pattern:
--
-- Callbacks.MouseDown(frame, callbackFunc, ...)

if nil ~= require then
	require "wow/Frame-Events";
	require "wow/Frame-Alpha";
	require "wow/Frame-Mouse";

	require "fritomod/currying";
	require "fritomod/Lists";
	require "fritomod/Timing";
	require "fritomod/ToggleDispatcher";
	require "fritomod/Callbacks";
	require "fritomod/Callbacks-Frames";
	require "fritomod/Functions";
	require "fritomod/log";
end;

Callbacks=Callbacks or {};

-- A helper function that ensures we only enable the mouse on a frame when
-- necessary. This coordination is necessary since different callbacks all
-- require an enabled mouse.
local function enableMouse(f)
    if not f.EnableMouse then
        return Noop;
    end;
	f.mouseListenerTypes=f.mouseListenerTypes or 0;
	f.mouseListenerTypes=f.mouseListenerTypes+1;
	f:EnableMouse(true);
	return Functions.OnlyOnce(function()
		f.mouseListenerTypes=f.mouseListenerTypes-1;
		if f.mouseListenerTypes <= 0 then
			f:EnableMouse(false);
		end;
	end)
end;

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

local function ToggledEvent(event, setUp, ...)
	setUp=Curry(setUp, ...);
	local eventListenerName=event.."Listeners";
	return function(frame, func, ...)
		frame = Frames.AsRegion(frame);
		assert(frame.SetScript,
			"Listener for "..event.." was not passed a frame, type was: "..type(frame)
		);
		func=Curry(func, ...);
		local dispatcher;
        Log.Enter("Frame Callbacks", "Adding callbacks", "Adding callback for", event, "event");
		if frame[eventListenerName] then
			dispatcher=frame[eventListenerName];
		else
			dispatcher=ToggleDispatcher:New(("%s (%s)"):format(event, tostring(frame)));
			dispatcher:AddInstaller(Tables.Change, frame, eventListenerName, dispatcher);
			setUp(dispatcher, frame);
		end;
		local remover = dispatcher:Add(func);
        Log.Leave();
        return remover;
	end;
end;

local function CheckForOverwrites(onEvent, offEvent, dispatcher, frame)
	dispatcher:AddInstaller(function()
		assert(not frame:GetScript(onEvent), "Refusing to overwrite the existing script handler for "..onEvent);
		assert(not frame:GetScript(offEvent), "Refusing to overwrite the existing script handler for "..offEvent);
	end);
end;

local function BasicEvent(onEvent, offEvent, dispatcher, frame)
	CheckForOverwrites(onEvent, offEvent, dispatcher, frame);
	dispatcher:AddInstaller(Callbacks.Script, frame, onEvent, dispatcher, "Fire");
	dispatcher:AddInstaller(Callbacks.Script, frame, offEvent, dispatcher, "Reset");
end;

-- Calls the specified callback whenever the mouse enters and leaves the specified frame.
Callbacks.EnterFrame = ToggledEvent("EnterFrame", function(dispatcher, frame)
	BasicEvent("OnEnter", "OnLeave", dispatcher, frame);
	dispatcher:AddInstaller(enableMouse, frame);
end);
Callbacks.MouseEnter=Callbacks.EnterFrame;
Callbacks.FrameEnter=Callbacks.EnterFrame;
Callbacks.MouseOver=Callbacks.EnterFrame;

function Callbacks.LeaveFrame(frame, func, ...)
	return Callbacks.EnterFrame(frame, Functions.ReverseUndoable(func, ...));
end;
Callbacks.MouseLeave=Callbacks.LeaveFrame;
Callbacks.FrameLeave=Callbacks.LeaveFrame;
Callbacks.MouseOut=Callbacks.LeaveFrame;

-- Calls the specified callback whenever the specified frame is shown.
Callbacks.ShowFrame = ToggledEvent("ShowFrame", BasicEvent, "OnShow", "OnHide");
function Callbacks.HideFrame(frame, func, ...)
	return Callbacks.ShowFrame(frame, Functions.ReverseUndoable(func, ...));
end;
Callbacks.FrameHidden=Callbacks.HideFrame;
Callbacks.FrameHide=Callbacks.HideFrame;

-- Calls the specified callback whenever the specified frame is focused
Callbacks.FocusGained = ToggledEvent("FocusGained", function(dispatcher, frame)
    BasicEvent("OnFocusGained", "OnFocusLost", dispatcher, frame);
    dispatcher:AddInstaller(ActivateKeyboard, frame);
end);

-- Calls the specified callback whenever dragging starts. You'll
-- need to manually call Frame:RegisterForDrag along with this method in order to
-- receive drag events. Frames.Draggable helps with this.
Callbacks.DragFrame = ToggledEvent("DragFrame", function(dispatcher, frame)
	BasicEvent("OnDragStart", "OnDragStop", dispatcher, frame);
	dispatcher:AddInstaller(enableMouse, frame);
end);

-- Calls the specified callback whenever dragging starts. You'll
-- need to manually call Frame:RegisterForDrag along with this method in order to
-- receive drag events. Frames.Draggable helps with this.
Callbacks.DragEnter = ToggledEvent("DragEnter", function(dispatcher, frame)
	BasicEvent("OnDragEnter", "OnDragLeave", dispatcher, frame);
	dispatcher:AddInstaller(function()
        if frame.AcceptDrops then
            frame:AcceptDrops();
        end;
    end);
end);
Callbacks.Drop = Headless(Callbacks.SimpleEvent, "OnDrop");

Callbacks.MouseDown = ToggledEvent("MouseDown", function(dispatcher, frame)
	CheckForOverwrites("OnMouseDown", "OnMouseUp", dispatcher, frame);
	dispatcher:AddInstaller(enableMouse, frame);
	local remover;
	local function OnMouseUp(reason, ...)
		trace("MouseUp detected (%s)", reason);
		if remover then
			remover();
			remover=nil;
		end;
		dispatcher:Reset(...);
	end;
	dispatcher:AddInstaller(Callbacks.Script, frame, "OnMouseDown", function(button, ...)
		trace("MouseDown detected");
		observed=button;
		dispatcher:Fire(button, ...);
        if platform() == "wow" then
            remover=Timing.OnUpdate(function()
                if observed ~= nil and not IsMouseButtonDown(observed) then
                    -- Ideally, this would never be needed, since OnMouseUp should always
                    -- fire. However, reparenting a frame causes the OnMouseUp event to be
                    -- lost. As a result, we need to simulate that event using OnUpdate.
                    --
                    -- This workaround is even used by Blizzard in FloatingChatFrame.xml.
                    -- If their workaround disappears, then ours can afford to go as well.
                    OnMouseUp("OnUpdate listener detected button was no longer pressed");
                end;
            end);
        end;
	end);
	dispatcher:AddInstaller(Callbacks.Script, frame, "OnMouseUp", OnMouseUp, "OnMouseUp event was fired");
	dispatcher:AddInstaller(Callbacks.HideFrame, frame, OnMouseUp, "Frame was hidden");
end);
function Callbacks.MouseUp(frame, func, ...)
	return Callbacks.MouseDown(frame, Functions.ReverseUndoable(func, ...));
end;

local CLICK_TOLERANCE=.5;
-- Calls the specified callback whenever a click begins on a frame.
function Callbacks.Click(f, func, ...)
	func=Curry(func, ...);
	if type(f) == "table" and #f > 0 then
		return Functions.OnlyOnce(Lists.CallEach,
			Lists.Each(f, Headless(Callbacks.Click, func))
		);
	end;
	f=Frames.AsRegion(f);
	assert(Frames.IsFrame(f), "Provided frame must be a true frame");
	assert(f.HasScript, "Provided frame must support script handlers");
	if f:HasScript("OnClick") then
		if not f.doClick then
			local listeners={};
			f.doClick=Functions.Spy(
				Curry(Lists.Insert, listeners),
				Functions.Install(function()
					return Curry(Lists.CallEach, {
						enableMouse(f),
						Callbacks.HookScript(f, "OnClick", Lists.CallEach, listeners)
					});
				end)
			);
		end;
		return f.doClick(func);
	end;
	return Callbacks.MouseDown(f, function(btn)
		local downTime=GetTime();
		return function(_, ...)
			local upTime=GetTime();
			if upTime-downTime < CLICK_TOLERANCE then
				func(btn, ...);
			end;
		end;
	end);
end;

function SpecificButtonClick(namedButton)
	return function(f, func, ...)
		func=Curry(func, ...);
		return Callbacks.Click(f, function(btn)
			if btn == namedButton then
				func();
			end;
		end);
	end;
end;

Callbacks.LeftClick = SpecificButtonClick("LeftButton");
Callbacks.RightClick = SpecificButtonClick("RightButton");
Callbacks.MiddleClick = SpecificButtonClick("MiddleButton");

Callbacks.MouseMove = Headless(Callbacks.Script, "OnMouseMove");

-- Returns the cursor's distance from the time this function was invoked.
--
-- The specified frame's scale will be used to adjust the distance. If no frame
-- is provided, UIParent is used. If you're using this function for frame
-- movement, you should provide the frame that is being moved.
function Callbacks.CursorOffset(frame, func, ...)
	frame = frame or UIParent;
	frame = Frames.AsRegion(frame);
	func = Curry(func, ...);
	local origX, origY=GetCursorPosition();
	local lastX, lastY=origX, origY;
	return Timing.OnUpdate(function()
		local x, y=GetCursorPosition();
		if lastX == x and lastY == y then
            return;
        end;
        lastX, lastY=x,y;
        func(
            (x-origX)/frame:GetEffectiveScale(),
            (y-origY)/frame:GetEffectiveScale()
        );
    end);
end;
Callbacks.MouseOffset=Callbacks.CursorOffset;

function Callbacks.DragThreshold(frame, threshold, buttons, callback, ...)
    callback = Curry(callback, ...);
    local conditional = Frames.ButtonTester(buttons);
    return Callbacks.MouseDown(frame, function(button, _, _, ...)
        if not conditional(button, ...) then
            return;
        end;
        local args = {...};
        local remover;
        remover = Callbacks.CursorOffset(frame, function(x, y)
            if Math.Hypotenuse(x, y) > threshold then
                remover();
                remover = callback(x, y, unpack(args));
                args = nil;
            end;
        end);
        return function()
            -- Wrap the function rather than returning it directly
            -- since we redefine the remover if the threshold is reached.
            if remover then
                remover();
                remover = nil;
            end;
        end;
    end);
end;

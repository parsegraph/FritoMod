-- Allows frames to be repositioned across the screen using the mouse
--[[

Frames.ThresholdDraggable(frame, 10, "Middle");

--]]
--
-- This file contains two useful functions for dragging frames: Frames.InstantDraggable
-- and Frames.ThresholdDraggable. Here's a quick example:
-- In the above example, the frame will start moving once you've moved your cursor at least
-- 10 pixels away from the start of the drag. This behaves similarly to WoW's dragging functions.
--
-- Sometimes, you'd prefer a frame to be dragged immediately. Frames.InstantDraggable does just that:
--
-- local r = Frames.InstantDraggable(frame, "Middle");
-- ... -- drag the frame around!
-- r(); -- Stop dragging
--
-- This works identically to the above, except the frame begins dragging immediately, rather than
-- waiting for a threshold to be exceeded.
--
-- If you omit button names, then the left and right buttons will be used as the defaults.
--
-- See also:
-- PersistentAnchor.lua
-- Anchors-Saved.lua

if nil ~= require then
	require "wow/Frame-Events";
	require "wow/api/Bindings";

	require "fritomod/Functions";
	require "fritomod/Lists";
	require "fritomod/Tables";
	require "fritomod/Callbacks-Mouse";
end;

Frames=Frames or {};

do
	local buttons={
		[{   "leftbutton",
			"left",
			"leftmouse",
			"mouse1"}]="LeftButton",

		[{   "rightbutton",
			"right",
			"rightmouse",
			"mouse2"}]="RightButton",

		[{   "middlebutton",
			"center",
			"mid",
			"middle",
			"middlemouse",
			"mouse3"}]="MiddleButton",

		[{   "button4",
			"mouse4",
			"thumb",
			"thumb1",
			"side1",
			"side"}]="Button4",

		[{   "button5",
			"mouse5",
			"side2",
			"thumb2"}]="Button5"
	};
	for k, v in pairs(buttons) do
		buttons[k] = function(candidate)
			return candidate == v;
		end;
	end;
	Tables.Expand(buttons);

	-- Returns the "proper" button name for a given alias. This lets
	-- us use plenty of different names without needing to remember the
	-- One True Way.
	function Frames.SimpleButtonTester(button)
		button=tostring(button);
		local tester = buttons[button:lower()];
		assert(tester, "Unknown button: " .. button);
		return tester;
	end;

	local modifiers={
		shift = Seal(IsShiftKeyDown),
		alt = Seal(IsAltKeyDown),
		control = Seal(IsControlKeyDown),
	};
	modifiers.meta = modifiers.alt;
	modifiers.ctrl = modifiers.control;
	modifiers["^"] = modifiers.control;

	function Frames.SimpleModifierTester(modifier)
		modifier=tostring(modifier);
		local modifierFunc = modifiers[modifier:lower()];
		assert(modifierFunc, "Unknown modifier: " .. modifier);
		return modifierFunc;
	end;
end;

do
	local function ConvertOneButton(button)
		if IsCallable(button) then
			return button;
		end;
		if type(button) == "table" then
			return Frames.ButtonTester(unpack(button));
		end;
		if button == nil then
			return Noop;
		end;
		assert(type(button)=="string", "button must be a string, got "..type(button));
		button = tostring(button);
		local parts = Strings.Split("[-_+.: ]", button);
		local buttonTester = Frames.SimpleButtonTester(Lists.PopOne(parts));
		parts = Lists.Map(parts, Frames.SimpleModifierTester);
		return function(button)
			for i=1, #parts do
				if not parts[i]() then
					return false;
				end;
			end;
			return buttonTester(button);
		end;
	end;

	function Frames.ButtonTester(...)
		if select("#", ...) == 0 then
			return Frames.ButtonTester("left", "right");
		end;
		local first = ...;
		if type(first) ~= "string" then
			return Curry(...);
		end;
		local buttons={...};
		assert(#buttons > 0, "At least one button must be provided.");
		for i=1, #buttons do
			buttons[i] = ConvertOneButton(buttons[i]);
		end;
		return function(button)
			for i=1, #buttons do
				if buttons[i](button) then
					return true;
				end;
			end;
			return false;
		end;
	end;
end;

do
	local function StartDrag(f, buttons)
		f:SetMovable(true);
		f:RegisterForDrag(unpack(buttons));
		f.dragRemover=Callbacks.DragFrame(f, Functions.Undoable(
			Seal(f, "StartMoving"),
			Seal(f, "StopMovingOrSizing")
		));
	end;
	local function StopDrag(f)
		f:StopMovingOrSizing();
		if f.dragRemover then
			f.dragRemover();
			f.dragRemover=nil;
		end;
		f:RegisterForDrag();
		f:SetMovable(false);
	end;
	function Frames.BlizzardDraggable(f, ...)
		local buttons={...};
		if #buttons==0 then
			buttons={"LeftButton", "RightButton"};
		elseif #buttons==1 and type(buttons[1])=="boolean" then
			if buttons[1] then
				StartDrag(f, {"LeftButton"});
			else
				StopDrag(f);
			end;
			return;
		end;
		StartDrag(f, buttons);
		return Functions.OnlyOnce(StopDrag, f);
	end;
end;

local function AdjustPoint(f)
	local center={f:GetCenter()};
	-- Remove scale for our points so they can be accurately compared.
	center[1]=  center[1]		  *f:GetEffectiveScale();
	center[2]=  center[2]		  *f:GetEffectiveScale();
	local right=UIParent:GetRight()*UIParent:GetEffectiveScale();
	local top=  UIParent:GetTop()  *UIParent:GetEffectiveScale();
	local possibilities={
		{ 0,	   0,	 "bottomleft" },
		{ right/2, 0,	 "bottom" },
		{ right,   0,	 "bottomright" },
		{ right,   top/2, "right" },
		{ right,   top,   "topright" },
		{ right/2, top,   "top" },
		{ 0,	   top,   "topleft" },
		{ 0,	   top/2, "left" },
		{ right/2, top/2, "center" },
	};
	local best, bestDistance;
	for _, candidate in ipairs(possibilities) do
		local candidateDistance=Math.Distance(candidate, center);
		if bestDistance==nil or candidateDistance < bestDistance then
			bestDistance=candidateDistance;
			best=candidate;
		end;
	end;
	f:ClearAllPoints();
	f:SetPoint("center", UIParent, best[3],
		(center[1]-best[1])/f:GetEffectiveScale(),
		(center[2]-best[2])/f:GetEffectiveScale()
	);
end;

function Frames.StartMovingFrame(frame, offsetX, offsetY)
	if frame.dragging then
		frame.dragging=frame.dragging+1;
	else
		if frame.FireEvent then
			frame:FireEvent("DragStart");
		end;

		frame.dragging=1;
		local startX, startY;
		if platform() == "wow" then
			startX, startY = frame:GetCenter();
		else
			startX, startY = frame:GetLeft(), frame:GetTop();
		end;
		assert(startX, "Frame must have a valid left position");
		assert(startY, "Frame must have a valid top position");

		if frame:GetParent() ~= UIParent and platform() == "wow" then
			-- Remove the local scale and re-add it once we've reparented. If we
			-- don't do this, startX and startY will use an out-of-date scale and
			-- will cause the frame to "jump" once it's first moved.
			startX=startX*frame:GetEffectiveScale();
			startY=startY*frame:GetEffectiveScale();
			frame:SetParent(UIParent);
			startX=startX/frame:GetEffectiveScale();
			startY=startY/frame:GetEffectiveScale();
		end;
		if offsetX then
			startX = startX + offsetX;
		end;
		if offsetY then
			startY = startY + offsetY;
		end;

		local function SetPoint(x, y)
			frame:ClearAllPoints();
			if platform() == "wow" then
				frame:SetPoint("center", frame:GetParent(), "bottomleft", startX+x, startY+y);
			else
				Anchors.Share(frame, "topleft", startX+x, startY+y);
			end;
		end;
		frame.dragBehavior = Callbacks.CursorOffset(frame, SetPoint);

		frame:ClearAllPoints();
		SetPoint(0, 0);
	end;
	return Functions.OnlyOnce(function()
		frame.dragging=frame.dragging-1;
		if frame.dragging <= 0 then
			frame.dragBehavior();
			if platform() == "wow" then
				AdjustPoint(frame);
			end;
			frame.dragBehavior=nil;
			frame.dragging=nil;

			if frame.FireEvent then
				frame:FireEvent("DragEnd");
			end;
		end;
	end);
end;

function Frames.ProxyDraggable(movedFrame, triggerFrame, ...)
	triggerFrame = Frames.AsRegion(triggerFrame);
	assert(triggerFrame.SetScript, "Frame does not support event listeners");

	movedFrame = Frames.AsRegion(movedFrame);

	local threshold, conditional;
	local first = ...;
	if type(first) == "number" then
		threshold = first;
		conditional = Frames.ButtonTester(select(2, ...));
	else
		threshold = 0;
		conditional = Frames.ButtonTester(...);
	end;

	return Callbacks.DragThreshold(
		triggerFrame,
		threshold,
		conditional,
		Frames.StartMovingFrame,
		movedFrame
	);
end;

function Frames.ThresholdDraggable(frame, ...)
	return Frames.ProxyDraggable(frame, frame, ...);
end;

function Frames.InstantDraggable(frame, ...)
	return Frames.ThresholdDraggable(frame, 0, ...);
end;

function Frames.Draggable(frame, ...)
	frame = Frames.AsRegion(frame);
	assert(frame.SetScript, "Frame does not support event listeners");

	if select("#", ...) == 0 then
		return Frames.InstantDraggable(frame);
	elseif select("#", ...) == 1 then
		local first = ...;
		if type(first) == "number" then
			return Frames.ThresholdDraggable(frame, ...);
		end;
		if type(first) == "table" and IsCallable(first.SetPoint) then
			return Frames.ProxyDraggable(frame, ...);
		end;
		return Frames.InstantDraggable(frame, ...);
	end;
	local first, second = ...;
	if type(first) == "number" then
		return Frames.ThresholdDraggable(frame, ...);
	end;
	if type(first) == "table" and IsCallable(first.SetPoint) then
		return Frames.ProxyDraggable(frame, ...);
	end;
	return Frames.InstantDraggable(frame, ...);
end;

-- vim: set noet :

-- A namespace of functions for frames.

if nil ~= require then
	require "wow/Frame-Layout";

	require "fritomod/Functions";
	require "fritomod/Media-Color";
end;

Frames=Frames or {};

function Frames.IsFrame(frame)
	return frame and
		type(frame)=="table" and
		type(frame.GetObjectType)=="function" and
		type(frame.SetPoint)=="function";
end;

function Frames.GetFrame(frame)
	if Frames.IsFrame(frame) then
		return frame;
	end;
	if type(frame)=="string" then
		return Frames.GetFrame(_G[frame]);
	end;
	assert(type(frame)=="table", "Frame must be a table.");
	if frame.Frame then
		return Frames.GetFrame(frame:Frame());
	end;
	return Frames.GetFrame(frame.frame);
end;

function Frames.Inject(frame)
	frame=Frames.GetFrame(frame);
	if Frames.IsInjected(frame) then
		return;
	end;
	local mt=getmetatable(frame).__index;
	frame._injected=mt;
	assert(type(mt)=="table", "Frame is not injectable");
	setmetatable(frame, {
		__index=function(self, k)
			return Frames[k] or Anchors[k] or mt[k];
		end
	});
	return frame;
end;

function Frames.IsInjected(frame)
	return Bool(frame._injected);
end;

local function CallOriginal(frame, name, ...)
	if Frames.IsInjected(frame) then
		return frame._injected[name](frame, ...);
	else
		return frame[name](frame, ...);
	end;
end;

function Frames.Child(frame, t, name, ...)
	frame=Frames.GetFrame(frame);
	local child=CreateFrame(t, name, frame, ...);
	if Frames.IsInjected(frame) then
		Frames.Inject(child);
	end;
	return child;
end;

-- Sets the size of the specified frame.
function Frames.Square(f, size)
	return Frames.Rectangle(f, size, size);
end;
Frames.Squared=Frames.Square;

function Frames.DumpPoints(f)
	f=Frames.GetFrame(f);
	for i=1,f:GetNumPoints() do
		print(f:GetPoint(i));
	end;
end;

-- Sets the dimensions for the specified frame.
function Frames.Rectangle(f, w, h)
	if h==nil then
		return Frames.Square(f, w);
	end;
	f=Frames.GetFrame(f);
	f:SetWidth(w);
	f:SetHeight(h);
end;
Frames.Rect=Frames.Rectangle;
Frames.Rectangular=Frames.Rectangle;
Frames.Size=Frames.Rectangle;

local INSETS_ZERO={
	left=0,
	top=0,
	bottom=0,
	right=0
};
function Frames.Insets(f)
	f=Frames.GetFrame(f);
	if f.GetBackdrop then
		local b=f:GetBackdrop();
		if b then
			return b.insets;
		end;
	end;
	return INSETS_ZERO;
end;

do
	-- Maximum value we'll tolerate before we give up.
	local TOLERANCE=3

	local function CheckOnePoint(f, ref, insets, i)
		local anchor, parent, anchorTo, x, y = f:GetPoint(i);
		trace("Checking point %d (%s to %s, x:%d, y:%d)", i, anchor, anchorTo, x, y);
		if parent and parent ~= ref then
			return TOLERANCE * 100;
		end;
		if anchorTo and anchor ~= anchorTo then
			return TOLERANCE * 100;
		end;
		local xdiff, ydiff = TOLERANCE, TOLERANCE;
		if anchor:match("LEFT$") then
			xdiff = abs(insets.left - x);
		elseif anchor:match("RIGHT$") then
			xdiff = abs(insets.right + x);
		end;
		if anchor:match("^TOP") then
			ydiff = abs(insets.top + y);
		elseif anchor:match("^BOTTOM") then
			ydiff = abs(insets.bottom - y);
		end;
		trace("xdiff is %d, ydiff is %d", xdiff, ydiff);
		return xdiff + ydiff;
	end;

	function Frames.IsInsetted(f, ref)
		f=Frames.GetFrame(f);
		ref=Frames.GetFrame(ref);
		local insets=Frames.Insets(ref);
		local matchDistance = 0;
		if f:GetNumPoints() < 2 then
			return false;
		end;
		for i=1, f:GetNumPoints() do
			matchDistance = matchDistance + CheckOnePoint(f, ref, insets, i);
		end;
		trace("Match distance was %d", matchDistance);
		return matchDistance < TOLERANCE * f:GetNumPoints();
	end;

	local function AdjustOnePoint(f, ref, insets, diff, i)
		local anchor, parent, anchorTo, x, y = f:GetPoint(i);
		if parent and parent ~= ref then
			return;
		end;
		if anchorTo and anchorTo ~= anchor then
			return;
		end;
		trace("Left %d %d %d", insets.left, x, diff.left);
		trace("Right %d %d %d", insets.right, x, diff.right);
		trace("Top %d %d %d", insets.top, y, diff.top);
		trace("Bottom %d %d %d", insets.bottom, y, diff.bottom);
		if anchor:match("LEFT$") and abs(insets.left - x) < TOLERANCE then
			x = x + diff.left;
		elseif anchor:match("RIGHT$") and abs(insets.right + x) < TOLERANCE then
			x = x + diff.right;
		end;
		if anchor:match("^TOP") and abs(insets.top + y) < TOLERANCE then
			y = y + diff.top;
		elseif anchor:match("^BOTTOM") and abs(insets.bottom - y) < TOLERANCE then
			y = y + diff.bottom;
		end;
		f:SetPoint(anchor, ref, anchor, x, y);
	end;

	function Frames.AdjustInsets(f, ref, oldInsets)
		f=Frames.GetFrame(f);
		ref=Frames.GetFrame(ref);
		local newInsets = Frames.Insets(ref);
		local diffs;
		if oldInsets then
			diffs = {
				left = newInsets.left - oldInsets.left,
				right = newInsets.right - oldInsets.right,
				top =  newInsets.top - oldInsets.top,
				bottom = newInsets.bottom - oldInsets.bottom
			};
			diffs.right = diffs.right * -1;
			diffs.top = diffs.top * -1;
		else
			diffs = newInsets;
		end;
		for i=1, f:GetNumPoints() do
			AdjustOnePoint(f, ref, oldInsets, diffs, i);
		end;
	end;
end;


-- Sets the alpha for a frame.
--
-- You don't need to use this function: we have it here when we use
-- Frames as a headless table.
function Frames.Alpha(f, alpha)
	f=Frames.GetFrame(f);
	f:SetAlpha(alpha);
end;
Frames.Opacity=Frames.Alpha;
Frames.Visibility=Frames.Alpha;

function Frames.Show(f)
	f=Frames.GetFrame(f);
	CallOriginal(f, "Show");
	return Functions.OnlyOnce(CallOriginal, f, "Hide");
end;

function Frames.Hide(f)
	f=Frames.GetFrame(f);
	CallOriginal(f, "Hide");
	return Functions.OnlyOnce(CallOriginal, f, "Show");
end;

function Frames.ToggleShowing(f)
	f=Frames.GetFrame(f);
	if f:IsVisible() then
		f:Hide();
	else
		f:Show();
	end;
end;
Frames.ToggleVisibility=Frames.ToggleShowing;
Frames.ToggleVisible=Frames.ToggleShowing;
Frames.ToggleShown=Frames.ToggleShowing;
Frames.ToggleShow=Frames.ToggleShowing;
Frames.ToggleHide=Frames.ToggleShowing;
Frames.ToggleHidden=Frames.ToggleShowing;

function Frames.Destroy(f)
	f=Frames.GetFrame(f);
	f:Hide();
	f:ClearAllPoints();
	f:SetParent(nil);
end;

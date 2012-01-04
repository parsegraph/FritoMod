-- A namespace of functions for frames.

if nil ~= require then
	require "wow/Frame-Layout";

	require "fritomod/Functions";
	require "fritomod/Media-Color";
end;

Frames=Frames or {};

function Frames.IsRegion(frame)
	return frame and
		type(frame)=="table" and
		type(frame.GetObjectType)=="function" and
		type(frame.SetPoint)=="function";
end;
Frames.IsFrame=Frames.IsRegion;

-- Returns the region that represents the specified object. Frames, regions, and their
-- subclasses are returned directly.
--
-- UI objects may provide a Frame method or a frame property that represents the frame
-- of that object. Frame-modifying methods will work on this frame. This allows UI objects
-- to be passed seamlessly into Frames and Anchors without needing to manually extract a
-- frame.
--
-- see also
-- 		Frames.AsAnchorable
-- 		Frames.IsRegion
function Frames.AsRegion(frame)
	if Frames.IsRegion(frame) then
		-- Frames represent themselves.
		return frame;
	end;
	if type(frame)=="string" then
		-- Frame names represent the frames they name.
		return _G[frame];
	end;
	assert(type(frame)=="table", "Frame must be a table. Got: "..type(frame));
	if frame.Frame then
		-- UI objects that have a Frame method are called directly to get their
		-- frame.
		return frame:Frame(), Frames.AsAnchorable(frame);
	end;
	-- UI objects may provide a frame property that will be used as the representative
	-- region
	return frame.frame, Frames.AsAnchorable(frame);
end;
Frames.GetFrame=Frames.AsRegion;

-- Returns an object that may be anchored. Frames, regions, and their subclasses are
-- returned directly.
--
-- UI objects may manage the reanchoring process themselves using an Anchor
-- method.  This Anchor method should expect an anchor name. The UI object is
-- responsible for reanchoring its children relative to the specified anchor
-- name. It is up to the UI object whether this change should result in a
-- visual appearance change or not.
function Frames.AsAnchorable(frame)
	if type(frame)=="table" and frame.Anchor then
		-- UI objects that provide an Anchor method can be anchored.
		return frame;
	end;
end;
Frames.GetAnchorable=Frames.AsAnchorable;

-- Returns a region that represents the bounds of the specified object. Frames, regions,
-- and their subclasses will be returned directly.
--
-- UI objects may provide a Bounds method or a bounds property that represents the bounding
-- box of that object. Anchoring methods will use this box when regions are anchored relative
-- to the specified UI object.
--
-- The UI object is solely responsible for ensuring the bounding box remains accurate.
function Frames.GetBounds(frame)
	if Frames.IsRegion(frame) then
		return frame;
	end;
	if type(frame)=="string" then
		return _G[frame];
	end;
	assert(type(frame)=="table", "Frame must be a table. Got: "..type(frame));
	if frame.Bounds then
		return frame:Bounds();
	end;
	if frame.bounds then
		return frame.bounds;
	end;
	return Frames.AsRegion(frame);
end;


do 
	local verticals = {
		TOPLEFT = "TOP",
		TOP = "TOP",
		TOPRIGHT = "TOP",
		BOTTOMLEFT = "BOTTOM",
		BOTTOM = "BOTTOM",
		BOTTOMRIGHT = "BOTTOM",
	};

	local horizontals = {
		TOPLEFT = "LEFT",
		BOTTOMLEFT = "LEFT",
		LEFT = "LEFT",
		TOPRIGHT = "RIGHT",
		RIGHT = "RIGHT",
		BOTTOMRIGHT = "RIGHT",
	}

	function Frames.VerticalComponent(anchor)
		return verticals[anchor];
	end;

	function Frames.HorizontalComponent(anchor)
		return horizontals[anchor];
	end;
end;

function Frames.Inject(frame)
	frame=Frames.AsRegion(frame);
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
	frame=Frames.AsRegion(frame);
	assert(frame.GetChildren, "Frame cannot handle children");
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
	f=Frames.AsRegion(f);
	for i=1,f:GetNumPoints() do
		print(f:GetPoint(i));
	end;
end;

function Frames.DumpPointsToList(f)
	f=Frames.AsRegion(f);
	local points = {};
	for i=1,f:GetNumPoints() do
		local anchor, ref, anchorTo, x, y = f:GetPoint(i);
		table.insert(points, {
			frame = f,
			anchor = anchor,
			ref = ref,
			anchorTo = anchorTo,
			x = x,
			y = y
		});
	end;
	return points;
end;

function Frames.DumpPointsToMap(f)
	f=Frames.AsRegion(f);
	local points = {};
	for i=1,f:GetNumPoints() do
		local anchor, ref, anchorTo, x, y = f:GetPoint(i);
		points[anchor] = {
			frame = f,
			anchor = anchor,
			ref = ref,
			anchorTo = anchorTo,
			x = x,
			y = y
		};
	end;
	return points;
end;

function Frames.DumpSharedPointsToList(f, ref)
	return Lists.FilterValues(Frames.DumpPointsToList(f), function(point)
		return points.ref == ref;
	end);
end;

-- Sets the dimensions for the specified frame.
function Frames.Rectangle(f, w, h)
	if h==nil then
		h=w;
	end;
	f=Frames.AsRegion(f);
	f:SetWidth(w);
	f:SetHeight(h);
end;
Frames.Rect=Frames.Rectangle;
Frames.Rectangular=Frames.Rectangle;
Frames.Size=Frames.Rectangle;

Frames.WidthHeight=Frames.Rectangle;
Frames.WH=Frames.WidthHeight;
function Frames.HeightWidth(f, h, w)
	Frames.Rectangle(f, w, h);
end;
Frames.HW=Frames.HeightWidth;

local INSETS_ZERO={
	left=0,
	top=0,
	bottom=0,
	right=0
};
function Frames.Insets(f)
	if f then
		f=Frames.AsRegion(f);
		if f and f.GetBackdrop then
			local b=f:GetBackdrop();
			if b then
				return b.insets;
			end;
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
		if anchor == "CENTER" then
			-- Ignore center anchor
			return 0;
		end;
		local xdiff, ydiff = 0, 0;
		if DEBUG_TRACE then
			trace("Top inset: %d", insets.top);
			trace("Left inset: %d", insets.left);
			trace("Right inset: %d", insets.right);
			trace("Bottom inset: %d", insets.bottom);
		end;
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
		f=Frames.AsRegion(f);
		ref=Frames.AsRegion(ref);
		local insets=Frames.Insets(ref);
		local matchDistance = 0;
		if f:GetNumPoints() < 2 then
			return false;
		end;
		for i=1, f:GetNumPoints() do
			matchDistance = matchDistance + CheckOnePoint(f, ref, insets, i);
		end;
		trace("Match distance was %d", matchDistance);
		local isInsetted = matchDistance < TOLERANCE * f:GetNumPoints();
		if isInsetted then
			trace("Frame is insetted");
		else
			trace("Frame is not insetted");
		end;
		return isInsetted;
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
		f=Frames.AsRegion(f);
		ref=Frames.AsRegion(ref);
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
	f=Frames.AsRegion(f);
	f:SetAlpha(alpha);
end;
Frames.Opacity=Frames.Alpha;
Frames.Visibility=Frames.Alpha;

function Frames.Show(f)
	f=Frames.AsRegion(f);
	CallOriginal(f, "Show");
	return Functions.OnlyOnce(CallOriginal, f, "Hide");
end;

function Frames.Hide(f)
	f=Frames.AsRegion(f);
	CallOriginal(f, "Hide");
	return Functions.OnlyOnce(CallOriginal, f, "Show");
end;

function Frames.IsVisible(f)
	f=Frames.AsRegion(f);
	return CallOriginal(f, "IsVisible");
end;

function Frames.ToggleShowing(f)
	f=Frames.AsRegion(f);
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
	f=Frames.AsRegion(f);
	f:Hide();
	f:ClearAllPoints();
	f:SetParent(nil);
end;

if nil ~= require then
	require "wow/Frame-Layout";
	require "fritomod/Strings";
end;

Anchors={};

local function GetAnchorArguments(frame, ...)
	local anchor, ref, x, y, parent;
	if type(select(1, ...)) == "string" then
		-- Since type() is a C function, it makes a nuisance of itself
		-- by demanding we always pass at least one argument. This is true
		-- even if the argument is nil. Since select(2, ...) can return
		-- nothing, we have to add the "or nil" to the end to be safe.
		if type(select(2, ...) or nil)=="number" then
			anchor, x, y=...;
		else
			anchor, ref, x, y=...;
		end;
	else
		ref, anchor, x, y=...;
	end;
	anchor=anchor:lower();
	if ref == nil then
		ref=frame:GetParent();
		parent=ref;
	else
		parent=Frames.GetFrame(ref);
		ref=Frames.GetBounds(ref);
	end;
	return anchor, ref, x, y, parent;
end;

local function FlipAnchor(name, reverses, signs, defaultSigns)
	for k,v in pairs(reverses) do
		reverses[v]=k;
	end;

	local function Gap(anchor, x, y)
		if not x then
			x=0;
		end;
		local sign=assert(signs[anchor], "Unrecognized anchor name: "..anchor);
		local sx, sy=unpack(sign);
		if not y then
			y=x;
			local defaults;
			if #defaultSigns > 0 then
				defaults=defaultSigns;
			else
				defaults=defaultSigns[anchor];
			end;
			sx, sy = defaults[1] * sx, defaults[2] * sy;
		end;
		return sx * x, sy * y;
	end;
	Anchors[name.."Gap"] = Gap;

	local function Flip(frame, ...)
		local anchorable;
		frame, anchorable=Frames.GetFrame(frame);
		local anchor, ref, x, y=GetAnchorArguments(frame, ...);
		local reverse = reverses[anchor];
		if anchorable then
			anchorable:Anchor(reverse);
		end;
		frame:SetPoint(reverse, ref, anchor, Gap(anchor, x, y));
	end

	Anchors[Strings.CharAt(name, 1).."Flip"] = Flip;
	Anchors[name.."Flip"]	 = Flip;
	Anchors[name.."Flip"]	 = Flip;
	Anchors[name.."Flipping"] = Flip;
	Anchors[name.."Flipped"]  = Flip;
	Anchors[name.."Over"]	 = Flip;
end;

-- Anchors.HorizontalFlip(f, "topright", ref);
-- +---+---+
-- |   | f |
-- |ref|---+
-- |   |
-- +---+
--
-- Anchors.HorizontalFlip(f, "right", ref);
-- +---+
-- |   |---+
-- |ref| f |
-- |   |---+
-- +---+
--
-- Anchors.HorizontalFlip(f, "bottomright", ref);
-- +---+
-- |   |
-- |ref|---+
-- |   | f |
-- +---+---+
--
-- Anchors.HorizontalFlip(f, "topleft", ref);
-- +---+---+
-- | f |   |
-- +---|ref|
--	 |   |
--	 +---+
--
-- Anchors.HorizontalFlip(f, "left", ref);
--	 +---+
-- +---|   |
-- | f |ref|
-- +---|   |
--	 +---+
--
-- Anchors.HorizontalFlip(f, "bottomleft", ref);
--	 +---+
--	 |   |
-- +---|ref|
-- | f |   |
-- +---+---+
FlipAnchor("Horizontal", {
		topleft	= "topright",
		bottomleft = "bottomright",
		left	   = "right",
	}, { -- Signs
		topright	=  {  1,  1 },
		right	   =  {  1,  1 },
		bottomright =  {  1, -1 },
		bottomleft  =  { -1, -1 },
		left		=  { -1,  1 },
		topleft	 =  { -1,  1 }
	}, { 1, 0 } -- Default mask
);

-- Anchors.VerticalFlip(f, "bottomleft", ref);
-- +-------+
-- |  ref  |
-- +-------+
-- | f |
-- +---+
--
-- Anchors.VerticalFlip(f, "bottom", ref);
-- +-------+
-- |  ref  |
-- +-------+
--   | f |
--   +---+
--
-- Anchors.VerticalFlip(f, "bottomright", ref);
-- +-------+
-- |  ref  |
-- +-------+
--	 | f |
--	 +---+
--
-- Anchors.VerticalFlip(f, "topleft", ref);
-- +---+
-- | f |
-- +-------+
-- |  ref  |
-- +-------+
--
-- Anchors.VerticalFlip(f, "top", ref);
--   +---+
--   | f |
-- +-------+
-- |  ref  |
-- +-------+
--
-- Anchors.VerticalFlip(f, "topright", ref);
--	 +---+
--	 | f |
-- +-------+
-- |  ref  |
-- +-------+
FlipAnchor("Vertical",
	{
		bottomright = "topright",
		bottomleft  = "topleft",
		bottom	  = "top"
	}, { -- Signs
		topright	=  {  1,  1 },
		top		 =  {  1,  1 },
		topleft	 =  { -1,  1 },
		bottomright =  {  1, -1 },
		bottom	  =  {  1, -1 },
		bottomleft  =  { -1, -1 }
	}, { 0, 1 } -- Default mask
);

-- "frame touches ref's anchor."
--
-- frame will be "flipped" over the reference frame. The centers of the two frames
-- will form a line that passes through the anchor.
-- Given a single number, convert it to the appropriate direction depending on
-- what anchor is used.
--
-- Positive gap values will increase the distance between frames.
-- Negative gap values will decrease the distance between frames.
--
-- The centers will form a line that passes through the anchor; diagonal anchor
-- points will cause the frames to separate diagonally.
--
-- Anchors.DiagonalFlip(f, "topleft", ref);
-- +---+
-- | f |
-- +---+---+
--	 |ref|
--	 +---+
--
-- Anchors.DiagonalFlip(f, "top", ref);
-- +---+
-- | f |
-- +---+
-- |ref|
-- +---+
--
-- Anchors.DiagonalFlip(f, "topright", ref);
--	 +---+
--	 | f |
-- +---+---+
-- |ref|
-- +---+
--
-- Anchors.DiagonalFlip(f, "right", ref);
-- +---+---+
-- |ref| f |
-- +---+---+
--
--
-- Anchors.DiagonalFlip(f, "bottomright", ref);
-- +---+
-- |ref|
-- +---+---+
--	 | f |
--	 +---+
--
-- Anchors.DiagonalFlip(f, "bottom", ref);
-- +---+
-- |ref|
-- +---+
-- | f |
-- +---+
--
-- Anchors.DiagonalFlip(f, "bottomleft", ref);
--	 +---+
--	 |ref|
-- +---+---+
-- | f |
-- +---+
--
-- Anchors.DiagonalFlip(f, "left", ref);
-- +---+---+
-- | f |ref|
-- +---+---+
FlipAnchor("Diagonal",
	{
		top	  = "bottom",
		right	= "left",
		topleft  = "bottomright",
		topright = "bottomleft",
	}, { -- Signs
		top		 = {  1,  1 },
		topright	= {  1,  1 },
		right	   = {  1,  1 },
		bottomright = {  1, -1 },
		bottom	  = {  1, -1 },
		bottomleft  = { -1, -1 },
		left		= { -1, -1 },
		topleft	 = { -1,  1 },
	}, { -- Defaults
		top		 = {  0,  1 },
		topright	= {  1,  1 },
		right	   = {  1,  0 },
		bottomright = {  1,  1 },
		bottom	  = {  0,  1 },
		bottomleft  = {  1,  1 },
		left		= {  1,  0 },
		topleft	 = {  1,  1 },
	}
);
Anchors.Flip=Anchors.DiagonalFlip;
Anchors.Flipping=Anchors.DiagonalFlip;
Anchors.Flipped=Anchors.DiagonalFlip;
Anchors.Over=Anchors.DiagonalOver;

local function EdgeFunctions(name)
	local func=Anchors[name];
	Anchors[name.."Left"]=function(frame, ref, x, y)
		func(frame, "topleft", ref, x, y);
		func(frame, "bottomleft", ref, x, y);
	end;
	Anchors[name.."Right"]=function(frame, ref, x, y)
		func(frame, "topright", ref, x, y);
		func(frame, "bottomright", ref, x, y);
	end;
	Anchors[name.."Top"]=function(frame, ref, x, y)
		func(frame, "topleft", ref, x, y);
		func(frame, "topright", ref, x, y);
	end;
	Anchors[name.."Bottom"]=function(frame, ref, x, y)
		func(frame, "bottomleft", ref, x, y);
		func(frame, "bottomright", ref, x, y);
	end;
end;

EdgeFunctions("HFlip");
EdgeFunctions("VFlip");
EdgeFunctions("DFlip");

Anchors.FlipTop   =Anchors.VFlipTop;
Anchors.FlipBottom=Anchors.VFlipBottom;

Anchors.FlipLeft =Anchors.HFlipLeft;
Anchors.FlipRight=Anchors.HFlipRight;

-- frame shares ref's anchor
function Anchors.Share(frame, ...)
	local anchorable;
	frame, anchorable=Frames.GetFrame(frame);
	local anchor, ref, x, y, parent=GetAnchorArguments(frame, ...);
	local insets=Frames.Insets(parent);
	if insets.top > 0 and anchor:find("^top") then
		y=y or 0;
		y=y+insets.top;
	elseif insets.bottom > 0 and anchor:find("^bottom") then
		y=y or 0;
		y=y+insets.bottom;
	end;
	if insets.left > 0 and anchor:find("left$") then
		x=x or 0;
		x=x+insets.left;
	elseif insets.right > 0 and anchor:find("right$") then
		x=x or 0;
		x=x+insets.right;
	end;
	if x ~= nil then
		x=-x;
	end;
	if y ~= nil then
		y=-y;
	end;
	if anchorable then
		anchorable:Anchor(anchor);
	end;
	frame:SetPoint(anchor, ref, anchor, Anchors.DiagonalGap(anchor, x, y));
end;
Anchors.Shares=Anchors.Share;
Anchors.Sharing=Anchors.Share;
Anchors.On=Anchors.Share;

EdgeFunctions("Share");

function Anchors.ShareAll(frame, ref, x, y)
	Anchors.Share(frame, "topleft", ref, x, y);
	Anchors.Share(frame, "bottomright", ref, x, y);
end;

function Anchors.Center(frame, ref)
	frame=Frames.GetFrame(frame);
	ref=Frames.GetBounds(ref);
	anchor=anchor or "center";
	frame:SetPoint(anchor, ref, "center");
end;

function Anchors.Set(frame, anchor, ref, anchorTo, x, y)
	frame=Frames.GetFrame(frame);
	ref=Frames.GetBounds(ref or frame:GetParent());
	frame:SetPoint(anchor, ref, anchorTo, x, y);
end;

function Anchors.Clear(frame)
	frame=Frames.GetFrame(frame);
	frame:ClearAllPoints();
end;

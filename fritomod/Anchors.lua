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
	anchor=anchor:upper();
	if ref == nil then
		ref=frame:GetParent();
		parent=ref;
	else
		parent=Frames.GetFrame(ref);
		ref=Frames.GetBounds(ref);
	end;
	assert(frame ~= ref, "Frame and ref must not be equal");
	return anchor, ref, x, y, parent;
end;

local function FlipAnchor(name, reverses, signs, defaultSigns, reverseJustify)
	for k,v in pairs(Tables.Clone(reverses)) do
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

	local function Flip(reversed, frame, ...)
		local anchorable;
		frame, anchorable=Frames.GetFrame(frame);
		local anchor, ref, x, y=GetAnchorArguments(frame, ...);
		local reverse = reverses[anchor];
		assert(reverse, "No reverse anchor found for "..name.." flip: "..anchor);
		if anchorable then
			anchorable:Anchor(reverse);
		end;
		x, y = Gap(anchor, x, y);
		assert(Frames.IsFrame(frame), "frame must be a frame. Got: "..type(frame));
		assert(Frames.IsFrame(ref), "ref must be a frame. Got: "..type(ref));
		if reversed then
			anchor, reverse = reverse, anchor;
		end;
		if DEBUG_TRACE then
			trace("%s flipping %s's %s over %s's %s (gap: %d, %d)",
				name,
				tostring(frame),
				reverse,
				tostring(ref),
				anchor,
				x,
				y);
		end;
		frame:SetPoint(anchor, ref, reverse, x, y);
	end

	local flipTo = Curry(Flip, true);
	Anchors[Strings.CharAt(name, 1).."Flip"] = flipTo;
	Anchors[name.."Flip"]	 = flipTo;
	Anchors[name.."FlipTo"]	 = flipTo;

	local flipFrom = Curry(Flip, false);
	Anchors[name.."FlipFrom"] = flipFrom;
	Anchors[Strings.CharAt(name, 1).."FlipFrom"] = flipFrom;

	Anchors[name.."AnchorName"] = function(anchor)
		anchor=anchor:upper();
		return reverses[anchor];
	end;

	local function Stack(towardsFirst, anchor, gap, ...)
		local frames;
		if Frames.IsFrame(gap) then
			frames={gap, ...};
			gap=0;
		elseif select("#", ...) == 0 and type(gap) == "table" then
			if Frames.IsFrame(gap) then
				frames = {gap}
			else
				frames = gap;
			end;
			gap=0;
		elseif select("#", ...) == 1 and not Frames.IsFrame(...) then
			frames = ...;
		else
			frames={...};
		end;
		local flipper = Anchors[name.."Flip"];
		local marcher=Lists.March;
		if towardsFirst then
			marcher=Lists.FlipMarch;
		end;
		local i=1;
		marcher(frames, function(first, second)
			local thisGap = gap;
			if IsCallable(thisGap) then
				thisGap = thisGap(first, second);
			elseif type(thisGap) == "table" and #thisGap > 0 then
				thisGap = thisGap[1 + (i % #thisGap)]
				i=i + 1;
			end;
			flipper(first, second, anchor, thisGap);
		end);
		if towardsFirst then
			return frames[1];
		else
			return frames[#frames];
		end;
	end;

	local stack = Curry(Stack, true);
	Anchors[name.."Stack"] = stack;
	Anchors[Strings.CharAt(name, 1).."Stack"] = stack;
	Anchors[name.."StackTo"] = stack;
	Anchors[Strings.CharAt(name, 1).."StackTo"] = stack;

	local reverseStack = Curry(Stack, false);
	Anchors["Reverse"..name.."Stack"] = reverseStack;
	Anchors["R"..Strings.CharAt(name, 1).."Stack"] = reverseStack;
	Anchors["Reverse"..name.."StackTo"] = reverseStack;
	Anchors["R"..Strings.CharAt(name, 1).."StackTo"] = reverseStack;

	local function StackFrom(towardsFirst, anchor, gap, ...)
		anchor=anchor:upper();
		return Stack(towardsFirst, reverses[anchor], gap, ...);
	end;
	local stackFrom = Curry(StackFrom, true);
	Anchors[name.."StackFrom"] = stackFrom;
	Anchors[Strings.CharAt(name, 1).."StackFrom"] = stackFrom;

	local reverseStackFrom = Curry(StackFrom, false);
	Anchors["Reverse"..name.."StackFrom"] = reverseStackFrom;
	Anchors["R"..Strings.CharAt(name, 1).."StackFrom"] = reverseStackFrom;

	local justifiers = {};
	local fromJustifiers = {};
	local reverseJustifiers = {};
	local reverseFromJustifiers = {};

	-- Similar to stack, but the relative arrangement of individual frames will
	-- remain in lexicographical order; the first element will (almost) always be
	-- furthest to the left and to the top.
	--
	-- In cases where there is ambiguity, left-to-right should be preferred over
	-- top-to-bottom.
	for anchor in pairs(reverses) do
		if reverseJustify[anchor] then
			justifiers[anchor] = reverseStack
			fromJustifiers[anchor] = stackFrom;
			reverseJustifiers[anchor] = stack
			reverseFromJustifiers[anchor] = reverseStackFrom;
		else
			justifiers[anchor] = stack;
			fromJustifiers[anchor] = reverseStackFrom;
			reverseJustifiers[anchor] = reverseStack;
			reverseFromJustifiers[anchor] = stackFrom;
		end;
	end;

	local function Justify(anchor, ...)
		return justifiers[anchor](anchor, ...);
	end;
	local function JustifyFrom(anchor, ...)
		return fromJustifiers[anchor](anchor, ...);
	end;
	local function ReverseJustify(anchor, ...)
		return reverseJustifiers[anchor](anchor, ...);
	end;
	local function ReverseJustifyFrom(anchor, ...)
		return reverseFromJustifiers[anchor](anchor, ...);
	end;

	Anchors[name.."Justify"] = Justify;
	Anchors[Strings.CharAt(name, 1).."Justify"] = Justify;
	Anchors[name.."JustifyTo"] = Justify;
	Anchors[Strings.CharAt(name, 1).."JustifyTo"] = Justify;

	Anchors[name.."JustifyFrom"] = JustifyFrom;
	Anchors[Strings.CharAt(name, 1).."JustifyFrom"] = JustifyFrom;

	Anchors["Reverse"..name.."Justify"] = ReverseJustify;
	Anchors["R"..Strings.CharAt(name, 1).."Justify"] = ReverseJustify;
	Anchors["Reverse"..name.."JustifyTo"] = ReverseJustify;
	Anchors["R"..Strings.CharAt(name, 1).."JustifyTo"] = ReverseJustify;

	Anchors["Reverse"..name.."JustifyFrom"] = ReverseJustifyFrom;
	Anchors["R"..Strings.CharAt(name, 1).."JustifyFrom"] = ReverseJustifyFrom;
end;

-- Anchors.HorizontalFlip(f, "TOPRIGHT", ref);
-- +---+---+
-- |   | f |
-- |ref|---+
-- |   |
-- +---+
--
-- Anchors.HorizontalFlip(f, "RIGHT", ref);
-- +---+
-- |   |---+
-- |ref| f |
-- |   |---+
-- +---+
--
-- Anchors.HorizontalFlip(f, "BOTTOMRIGHT", ref);
-- +---+
-- |   |
-- |ref|---+
-- |   | f |
-- +---+---+
--
-- Anchors.HorizontalFlip(f, "TOPLEFT", ref);
-- +---+---+
-- | f |   |
-- +---|ref|
--     |   |
--     +---+
--
-- Anchors.HorizontalFlip(f, "LEFT", ref);
--     +---+
-- +---|   |
-- | f |ref|
-- +---|   |
--     +---+
--
-- Anchors.HorizontalFlip(f, "BOTTOMLEFT", ref);
--     +---+
--     |   |
-- +---|ref|
-- | f |   |
-- +---+---+
FlipAnchor("Horizontal", {
		TOPLEFT	= "TOPRIGHT",
		BOTTOMLEFT = "BOTTOMRIGHT",
		LEFT	   = "RIGHT",
	}, { -- Signs
		TOPRIGHT	=  {  1,  1 },
		RIGHT	   =  {  1,  1 },
		BOTTOMRIGHT =  {  1, -1 },
		BOTTOMLEFT  =  { -1, -1 },
		LEFT		=  { -1,  1 },
		TOPLEFT	 =  { -1,  1 }
	}, { 1, 0 }, -- Default mask
	{
		TOPLEFT = true,
		LEFT = true,
		BOTTOMLEFT = true
	}
);

-- Anchors.VerticalFlip(f, "BOTTOMLEFT", ref);
-- +-------+
-- |  ref  |
-- +-------+
-- | f |
-- +---+
--
-- Anchors.VerticalFlip(f, "BOTTOM", ref);
-- +-------+
-- |  ref  |
-- +-------+
--   | f |
--   +---+
--
-- Anchors.VerticalFlip(f, "BOTTOMRIGHT", ref);
-- +-------+
-- |  ref  |
-- +-------+
--     | f |
--     +---+
--
-- Anchors.VerticalFlip(f, "TOPLEFT", ref);
-- +---+
-- | f |
-- +-------+
-- |  ref  |
-- +-------+
--
-- Anchors.VerticalFlip(f, "TOP", ref);
--   +---+
--   | f |
-- +-------+
-- |  ref  |
-- +-------+
--
-- Anchors.VerticalFlip(f, "TOPRIGHT", ref);
--     +---+
--     | f |
-- +-------+
-- |  ref  |
-- +-------+
FlipAnchor("Vertical",
	{
		BOTTOMRIGHT = "TOPRIGHT",
		BOTTOMLEFT  = "TOPLEFT",
		BOTTOM	  = "TOP"
	}, { -- Signs
		TOPRIGHT	=  {  1,  1 },
		TOP		 =  {  1,  1 },
		TOPLEFT	 =  { -1,  1 },
		BOTTOMRIGHT =  {  1, -1 },
		BOTTOM	  =  {  1, -1 },
		BOTTOMLEFT  =  { -1, -1 }
	}, { 0, 1 }, -- Default mask
	{
		TOPLEFT = true,
		TOP = true,
		TOPRIGHT = true
	}
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
-- Anchors.DiagonalFlip(f, "TOPLEFT", ref);
-- +---+
-- | f |
-- +---+---+
--     |ref|
--     +---+
--
-- Anchors.DiagonalFlip(f, "TOP", ref);
-- +---+
-- | f |
-- +---+
-- |ref|
-- +---+
--
-- Anchors.DiagonalFlip(f, "TOPRIGHT", ref);
--     +---+
--     | f |
-- +---+---+
-- |ref|
-- +---+
--
-- Anchors.DiagonalFlip(f, "RIGHT", ref);
-- +---+---+
-- |ref| f |
-- +---+---+
--
--
-- Anchors.DiagonalFlip(f, "BOTTOMRIGHT", ref);
-- +---+
-- |ref|
-- +---+---+
--     | f |
--     +---+
--
-- Anchors.DiagonalFlip(f, "BOTTOM", ref);
-- +---+
-- |ref|
-- +---+
-- | f |
-- +---+
--
-- Anchors.DiagonalFlip(f, "BOTTOMLEFT", ref);
--     +---+
--     |ref|
-- +---+---+
-- | f |
-- +---+
--
-- Anchors.DiagonalFlip(f, "LEFT", ref);
-- +---+---+
-- | f |ref|
-- +---+---+
FlipAnchor("Diagonal",
	{
		TOP	  = "BOTTOM",
		RIGHT	= "LEFT",
		TOPLEFT  = "BOTTOMRIGHT",
		TOPRIGHT = "BOTTOMLEFT",
	}, { -- Signs
		TOP		 = {  1,  1 },
		TOPRIGHT	= {  1,  1 },
		RIGHT	   = {  1,  1 },
		BOTTOMRIGHT = {  1, -1 },
		BOTTOM	  = {  1, -1 },
		BOTTOMLEFT  = { -1, -1 },
		LEFT		= { -1, -1 },
		TOPLEFT	 = { -1,  1 },
	}, { -- Defaults
		TOP		 = {  0,  1 },
		TOPRIGHT	= {  1,  1 },
		RIGHT	   = {  1,  0 },
		BOTTOMRIGHT = {  1,  1 },
		BOTTOM	  = {  0,  1 },
		BOTTOMLEFT  = {  1,  1 },
		LEFT		= {  1,  0 },
		TOPLEFT	 = {  1,  1 },
	}, {
		TOP = true,
		TOPLEFT = true,
		LEFT = true,
		BOTTOMLEFT = true,
	}
);
Anchors.Flip=Anchors.DiagonalFlip;
Anchors.FlipTo=Anchors.Flip;

Anchors.FlipFrom=Anchors.DiagonalFlipFrom;

Anchors.Stack=Anchors.DiagonalStack;
Anchors.ReverseStack=Anchors.ReverseDiagonalStack;
Anchors.RStack=Anchors.ReverseStack;

Anchors.StackTo=Anchors.DiagonalStack;
Anchors.ReverseStackTo=Anchors.ReverseDiagonalStack;
Anchors.RStackTo=Anchors.ReverseStack;

Anchors.StackFrom=Anchors.DiagonalStackFrom;
Anchors.ReverseStackFrom=Anchors.ReverseDiagonalStackFrom;
Anchors.RStackFrom=Anchors.ReverseStackFrom;

Anchors.Justify=Anchors.DiagonalJustify;
Anchors.ReverseJustify=Anchors.ReverseDiagonalJustify;
Anchors.RJustify=Anchors.ReverseJustify;

Anchors.JustifyTo=Anchors.DiagonalJustify;
Anchors.ReverseJustifyTo=Anchors.ReverseDiagonalJustify;
Anchors.RJustifyTo=Anchors.ReverseJustify;

Anchors.JustifyFrom=Anchors.DiagonalJustifyFrom;
Anchors.ReverseJustifyFrom=Anchors.ReverseDiagonalJustifyFrom;
Anchors.RJustifyFrom=Anchors.ReverseJustifyFrom;

local function EdgeFunctions(name)
	local func=Anchors[name];
	Anchors[name.."Left"]=function(frame, ref, x, y)
		func(frame, "TOPLEFT", ref, x, y);
		func(frame, "BOTTOMLEFT", ref, x, y);
	end;
	Anchors[name.."Right"]=function(frame, ref, x, y)
		func(frame, "TOPRIGHT", ref, x, y);
		func(frame, "BOTTOMRIGHT", ref, x, y);
	end;
	Anchors[name.."Top"]=function(frame, ref, x, y)
		func(frame, "TOPLEFT", ref, x, y);
		func(frame, "TOPRIGHT", ref, x, y);
	end;
	Anchors[name.."Bottom"]=function(frame, ref, x, y)
		func(frame, "BOTTOMLEFT", ref, x, y);
		func(frame, "BOTTOMRIGHT", ref, x, y);
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
	if insets.top > 0 and Strings.StartsWith(anchor, "TOP") then
		y=y or 0;
		y=y+insets.top;
	elseif insets.bottom > 0 and Strings.StartsWith(anchor, "BOTTOM") then
		y=y or 0;
		y=y+insets.bottom;
	end;
	if insets.left > 0 and Strings.EndsWith(anchor, "LEFT") then
		x=x or 0;
		x=x+insets.left;
	elseif insets.right > 0 and Strings.EndsWith(anchor, "RIGHT") then
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

local function MultipleShare(anchor, ...)
	local anchors = {anchor, ...};
	return function(frame, ref, x, y)
		-- We call GetFrame here to avoid calling anchorable:Anchor since it would
		-- be ambiguous.
		for i=1, #anchors do
			Anchors.Share(frame, anchors[i], ref, x, y);
		end;
	end;
end;

Anchors.ShareAll = MultipleShare("LEFT", "RIGHT", "TOP", "BOTTOM");
Anchors.ShareOrthogonals = Anchors.ShareAll;
Anchors.ShareDiagonals = MultipleShare("TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT");
Anchors.ShareVertical = MultipleShare("TOP", "BOTTOM");
Anchors.ShareHorizontal = MultipleShare("LEFT", "RIGHT");

function Anchors.Center(frame, ref)
	local anchorable;
	frame,anchorable=Frames.GetFrame(frame);
	ref=ref or frame:GetParent();
	ref=Frames.GetBounds(ref);
	anchor=anchor or "CENTER";
	if anchorable then
		anchorable:Anchor("CENTER");
	end;
	frame:SetPoint(anchor, ref, "center");
end;

function Anchors.Set(frame, anchor, ref, anchorTo, x, y)
	frame=Frames.GetFrame(frame);
	ref=Frames.GetBounds(ref or frame:GetParent());
	frame:SetPoint(anchor, ref, anchorTo, x, y);
end;

function Anchors.Clear(...)
	for i=1, select("#", ...) do
		local frame = select(i, ...);
		frame=Frames.GetFrame(frame);
		frame:ClearAllPoints();
	end;
end;

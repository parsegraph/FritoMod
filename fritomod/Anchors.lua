if nil ~= require then
	require "wow/Frame-Layout";
	require "wow/Frame-Container";
	require "fritomod/Strings";
	require "fritomod/Metatables";
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
	anchor = anchor:upper();
	if not ref then
		ref = assert(Frames.AsRegion(frame), "Frame or UI object has no parent"):GetParent()
	end;
	return anchor, ref, x, y;
end;

--- Returns an object that may be anchored. Frames, regions, and their subclasses are
--- returned directly.
---
--- UI objects may manage the reanchoring process themselves using an Anchor
--- method.  This Anchor method should expect an anchor name. The UI object is
--- responsible for reanchoring its children relative to the specified anchor
--- name. It is up to the UI object whether this change should result in a
--- visual appearance change or not.
local function GetAnchorable(frame, anchor)
	return Frames.AsRegion(frame) or GetAnchorable(frame:Anchor(anchor), anchor);
end;

-- Returns a region that represents the bounds of the specified object. Frames, regions,
-- and their subclasses will be returned directly.
--
-- UI objects must provid a Bounds method that will return a region that at that corner
-- of the UI object. Anchoring operations will use the returned region as the reference
-- anchor.
--
-- UI objects may also return another UI object. In this case, GetBounds will recurse
-- until a real region is found.
local function GetBounds(frame, anchor)
	return Frames.AsRegion(frame) or GetBounds(frame:Bounds(anchor), anchor);
end;

-- Return the gap and a table containing the frames given in the arguments. This
-- handles a few different styles of arguments for convenience, so it should be used
-- when writing anchor functions that involve multiple frames combined with a gap.
local function GetGapAndFrames(gap, ...)
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
	return gap, frames;
end;

local function InjectIntoAnchors(format, name, func, ...)
	func=Curry(func, ...);
	if type(format) == "table" then
		for i=1, #format do
			InjectIntoAnchors(format[i], name, func);
		end;
		return;
	end;
	if type(name) == "table" then
		for i=1, #name do
			InjectIntoAnchors(format, name[i], func);
		end;
		return;
	end;
	Anchors[format:format(name)] = func;
end;

local function FullStrategyName(name)
	if type(name) == "string" then
		return name;
	end;
	return name[1];
end;

local function GapAnchorStrategy(name, signs, masks)
	if IsCallable(signs) then
		InjectIntoAnchors("%sGap", name, signs);
		return;
	end;
	InjectIntoAnchors("%sGap", name, function(anchor, x, y, ref)
		if not x then
			x=0;
		end;
		anchor = tostring(anchor):upper();
		local sign=signs[anchor];
		if not sign then
			assert(
				(x == nil or x == 0) and
				(y == nil or y == 0),
				"Anchor is not supported: "..anchor
			);
			return 0, 0;
		end;
		assert(tonumber(x), "X must be a number. Given: "..tostring(x));
		local sx, sy=unpack(sign);
		if not y then
			y=x;
			local mask;
			if #masks > 0 then
				mask=masks;
			else
				mask=masks[anchor];
			end;
			sx, sy = mask[1] * sx, mask[2] * sy;
		end;
		assert(tonumber(y), "Y must be a number. Given: "..tostring(y));
		return sx * x, sy * y;
	end);
end;

local function AnchorPairStrategy(name, anchorPairs)
	for k,v in pairs(Tables.Clone(anchorPairs)) do
		anchorPairs[v]=k;
	end;

	InjectIntoAnchors("%sAnchorPair", name, function(anchor)
		assert(anchor, "Anchor must not be falsy");
		anchor=anchor:upper();
		return anchorPairs[anchor];
	end);

	InjectIntoAnchors("%sAnchorPairs", name, function()
		return anchorPairs;
	end);
end;

local function AnchorSetStrategy(name, setVerb)
	if type(setVerb) == "table" then
		for i=1, #setVerb do
			AnchorSetStrategy(name, setVerb[i]);
		end;
		return;
	end;

	local fullName = FullStrategyName(name);
	local Gap = Anchors[fullName.."Gap"];
	local AnchorPair = Anchors[fullName.."AnchorPair"];

	InjectIntoAnchors(setVerb, name, function(frame, ...)
		local anchor, ref, x, y=GetAnchorArguments(frame, ...);
		local anchorTo = AnchorPair(anchor);
		assert(anchorTo, "No anchor pair found for "..fullName.." set: "..anchor);
		Anchors.Set(frame, anchor, ref, anchorTo, Gap(anchorTo, x, y, ref));
	end);
end;

local function ReverseAnchorSetStrategy(name, setVerb, reversingVerb)
	if type(setVerb) == "table" then
		for i=1, #setVerb do
			ReverseAnchorSetStrategy(name, setVerb[i], reversingVerb);
		end;
		return;
	end;
	local fullName = FullStrategyName(name);

	if type(reversingVerb) == "table" then
		reversingVerb = reversingVerb[1];
	end;

	local AnchorPair = Anchors[fullName.."AnchorPair"];
	local Gap = Anchors[fullName.."Gap"];

	InjectIntoAnchors(
		setVerb,
		name,
		function(frame, ...)
			local anchor, ref, x, y=GetAnchorArguments(frame, ...);
			local anchorTo = AnchorPair(anchor);
			assert(anchorTo, "No anchor pair found for "..fullName.." set: "..anchor);
			Anchors.Set(frame, anchorTo, ref, anchor, Gap(anchor, x, y, ref));
		end
	);
end;

local function EdgeSetStrategy(name, setVerb)
	local fullName = FullStrategyName(name);

	if type(setVerb) == "table" then
		for i=1, #setVerb do
			EdgeSetStrategy(name, setVerb[i]);
		end;
		return;
	end;
	local SetPoint = Anchors[setVerb:format(fullName)];

	local function FlipEdge(...)
		local anchors = {...};
		return function(frame, ref, x, y)
			for i=1, #anchors do
				SetPoint(frame, anchors[i], ref, x, y);
			end;
		end;
	end;
	InjectIntoAnchors(setVerb.."Left",
		name,
		FlipEdge("TOPLEFT", "BOTTOMLEFT")
	);
	InjectIntoAnchors(setVerb.."Right",
		name,
		FlipEdge("TOPRIGHT", "BOTTOMRIGHT")
	);
	InjectIntoAnchors(setVerb.."Top",
		name,
		FlipEdge("TOPLEFT", "TOPRIGHT")
	);
	InjectIntoAnchors(setVerb.."Bottom",
		name,
		FlipEdge("BOTTOMLEFT", "BOTTOMRIGHT")
	);
	InjectIntoAnchors(setVerb.."All",
		name,
		FlipEdge("LEFT", "RIGHT", "TOP", "BOTTOM")
	);
	InjectIntoAnchors(setVerb.."Orthogonal",
		name,
		FlipEdge("LEFT", "RIGHT", "TOP", "BOTTOM")
	);
	InjectIntoAnchors(setVerb.."Diagonals",
		name,
		FlipEdge("TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT")
	);
	InjectIntoAnchors(setVerb.."Verticals",
		name,
		FlipEdge("TOP", "BOTTOM")
	);
	InjectIntoAnchors(setVerb.."Horizontals",
		name,
		FlipEdge("LEFT", "RIGHT")
	);
end;

local function StackStrategy(name, defaultAnchor)
	local fullName = FullStrategyName(name);

	if type(setVerb) == "table" then
		setVerb = setVerb[1];
	end;
	local FlipTo = Anchors[fullName.."FlipTo"];
	local AnchorPair = Anchors[fullName.."AnchorPair"];

	local function Stack(towardsFirst, anchor, gap, ...)
		anchor=anchor:upper();
		if anchor == "CENTER" and defaultAnchor then
			local CStack = Anchors[fullName.."CStack"];
			return CStack(defaultAnchor, ...);
		end;
		local frames;
		gap, frames = GetGapAndFrames(gap, ...);
		local marcher=Lists.March;
		if towardsFirst then
			-- We want A<B<C (stack from the right), so we need to reverse-march
			-- so we get the following moves:
			--
			-- Flip(C, B)
			-- Flip(B, A)
			--
			-- This is a reverse march, with the "first" frame being the anchor
			-- (or reference).
			--
			-- We don't need to get the paired anchor, since each subsequent frame
			-- will be flipped over the previous frame's point.
			marcher=Lists.ReverseMarch;
		else
			-- We want A>B>C (stack to the right). This is accomplished by:
			-- Flip(A, B)
			-- Flip(B, C)
			--
			-- Each subsequent frame is to the right of the previous frame,
			-- with the last frame being the anchor (or reference).
			--
			-- We need to get the paired anchor, since the flips are based off
			-- the reference's opposing anchor.
			anchor=AnchorPair(anchor);
		end;
		local i=1;
		return marcher(frames, function(first, second)
			local thisGap = gap;
			if IsCallable(thisGap) then
				thisGap = thisGap(first, second);
			elseif type(thisGap) == "table" and #thisGap > 0 then
				thisGap = thisGap[1 + (i % #thisGap)]
				i=i + 1;
			end;
			FlipTo(first, second, anchor, thisGap);
		end);
	end
	InjectIntoAnchors({
			"%sStack",
			"%sStackTo"
		},
		name,
		Curry(Stack, false)
	);

	local AnchorPair = Anchors[FullStrategyName(name) .. "AnchorPair"];

	InjectIntoAnchors(
		"%sStackFrom",
		name,
		Curry(Stack, true)
	);
end;

local function CenterStackStrategy(name)
	local fullName = FullStrategyName(name);
	local StackFrom = Anchors[fullName.."StackFrom"];
	local StackTo = Anchors[fullName.."StackTo"];

	InjectIntoAnchors({
			"%sCStack",
			"%sCenterStack",
		},
		name,
		function(anchor, gap, ...)
			anchor=anchor:upper();
			local gap, frames = GetGapAndFrames(gap, ...);
			local count = #frames;
			local mid;
			if count % 2 == 0 then
				-- We have an even number of frames, so
				-- we need to pick one arbitrarily to be
				-- the "middle".
				mid = count / 2;
			else
				mid = (count + 1) / 2;
			end;
			-- Align the leading slice
			StackTo(anchor, gap,
				Lists.Slice(frames, 1, mid));
			-- Align the trailing slice
			StackFrom(anchor, gap,
				Lists.Slice(frames, mid, #frames));
			-- Return the middle
			return frames[mid];
		end
	);
end;

local function JustifyStrategy(name, reverseJustify, defaultAnchor)
	local fullName = FullStrategyName(name);
	local AnchorPair = Anchors[fullName.."AnchorPair"];

	local StackTo = Anchors[fullName.."StackTo"];
	local StackFrom = Anchors[fullName.."StackFrom"];

	InjectIntoAnchors({
			"%sJustify",
			"%sJustifyTo"
		},
		name,
		function(anchor, ...)
			anchor=anchor:upper();
			if anchor == "CENTER" and defaultAnchor then
				local CJustify = Anchors[fullName.."CJustify"];
				return CJustify(defaultAnchor, ...);
			end;
			if reverseJustify[anchor] then
				return StackFrom(AnchorPair(anchor), ...);
			end;
			return StackTo(anchor, ...);
		end
	);
	InjectIntoAnchors(
		"%sJustifyFrom",
		name,
		function(anchor, ...)
			anchor=anchor:upper();
			if anchor == "CENTER" and defaultAnchor then
				local CJustify = Anchors[fullName.."CJustify"];
				return CJustify(defaultAnchor, ...);
			end;
			if reverseJustify[anchor] then
				return StackTo(AnchorPair(anchor), ...);
			end;
			return StackFrom(anchor, ...);
		end
	);
end;

local function CenterJustifyStrategy(name, reverseJustify)
	local fullName = FullStrategyName(name);
	local AnchorPair = Anchors[fullName.."AnchorPair"];
	local CStack = Anchors[fullName.."CStack"];

	InjectIntoAnchors({
			"%sCJustify",
			"%sCenterJustify",
		},
		name,
		function(anchor, ...)
			anchor=anchor:upper();
			if reverseJustify[anchor] then
				return CStack(AnchorPair(anchor), ...);
			end;
			return CStack(anchor, ...);
		end
	);
end;


local strategies = {};

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

strategies.Horizontal = {
	name = {"Horizontal", "H"},
	gapSigns = {
		TOPRIGHT	=  {  1,  1 },
		RIGHT	   =  {  1,  1 },
		BOTTOMRIGHT =  {  1, -1 },
		BOTTOMLEFT  =  { -1, -1 },
		LEFT		=  { -1,  1 },
		TOPLEFT	 =  { -1,  1 }
	},
	gapMask = { 1, 0 },
	anchorPairs = {
		TOPLEFT	= "TOPRIGHT",
		BOTTOMLEFT = "BOTTOMRIGHT",
		LEFT	   = "RIGHT"
	},
	setVerb = "%sFlipFrom",
	reverseSetVerb = { "%sFlipTo", "%sFlip" },
	reverseJustify = {
		TOPLEFT = true,
		LEFT = true,
		BOTTOMLEFT = true
	},
	defaultAnchor = "RIGHT"
};

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

strategies.Vertical = {
	name = {"Vertical", "V"},
	gapSigns = {
		TOPRIGHT	=  {  1,  1 },
		TOP		 =  {  1,  1 },
		TOPLEFT	 =  { -1,  1 },
		BOTTOMRIGHT =  {  1, -1 },
		BOTTOM	  =  {  1, -1 },
		BOTTOMLEFT  =  { -1, -1 }
	},
	gapMask = { 0, 1 },
	anchorPairs = {
		BOTTOMRIGHT = "TOPRIGHT",
		BOTTOMLEFT  = "TOPLEFT",
		BOTTOM	  = "TOP"
	},
	setVerb = "%sFlipFrom",
	reverseSetVerb = { "%sFlipTo", "%sFlip" },
	reverseJustify = {
		TOPLEFT = true,
		TOP = true,
		TOPRIGHT = true
	},
	defaultAnchor = "BOTTOM"
};

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

strategies.Diagonal = {
	name = {
		"Diagonal",
		"D",
		""
	},
	gapSigns = {
		TOP		 = {  1,  1 },
		TOPRIGHT	= {  1,  1 },
		RIGHT	   = {  1,  1 },
		BOTTOMRIGHT = {  1, -1 },
		BOTTOM	  = {  1, -1 },
		BOTTOMLEFT  = { -1, -1 },
		LEFT		= { -1, -1 },
		TOPLEFT	 = { -1,  1 },
	},
	gapMask = {
		TOP		 = {  0,  1 },
		TOPRIGHT	= {  1,  1 },
		RIGHT	   = {  1,  0 },
		BOTTOMRIGHT = {  1,  1 },
		BOTTOM	  = {  0,  1 },
		BOTTOMLEFT  = {  1,  1 },
		LEFT		= {  1,  0 },
		TOPLEFT	 = {  1,  1 },
	},
	anchorPairs = {
		TOP	  = "BOTTOM",
		RIGHT	= "LEFT",
		TOPLEFT  = "BOTTOMRIGHT",
		TOPRIGHT = "BOTTOMLEFT",
	},
	setVerb = "%sFlipFrom",
	reverseSetVerb = { "%sFlipTo", "%sFlip" },
	reverseJustify = {
		TOP = true,
		TOPLEFT = true,
		LEFT = true,
		BOTTOMLEFT = true,
	},
	defaultAnchor = "RIGHT"
};

strategies.ShareInner = {
	name = {
		"Shared",
		"Sharing",
		"S",
	},
	gapSigns = function(anchor, x, y, ref)
		anchor=tostring(anchor):upper();
		assert(ref, "Reference frame must be provided for determining gap strategy");
		local insets=Frames.Insets(ref);
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
		return Anchors.DiagonalGap(anchor, x, y);
	end,
	anchorPairs = {
		RIGHT  = "RIGHT",
		TOPRIGHT  = "TOPRIGHT",
		TOP = "TOP",
		TOPLEFT  = "TOPLEFT",
		BOTTOMRIGHT  = "BOTTOMRIGHT",
		BOTTOM = "BOTTOM",
		BOTTOMLEFT  = "BOTTOMLEFT",
		LEFT  = "LEFT",
		CENTER = "CENTER",
	},
	setVerb = {"Share", "ShareInner"},
};

strategies.ShareOuter = setmetatable({
		name = {
			"OuterShared",
			"OuterSharing",
			"OS"
		},
		setVerb = "ShareOuter",
		gapSigns = function(anchor, x, y, ref)
			if x ~= nil then
				x=-x;
			end;
			if y ~= nil then
				y=-y;
			end;
			return Anchors.DiagonalGap(anchor, x, y);
		end
	}, {
		__index = strategies.ShareInner
});

for _, strategy in pairs(strategies) do
	local name = strategy.name;
	GapAnchorStrategy(
		name,
		strategy.gapSigns,
		strategy.gapMask
	);
	AnchorPairStrategy(name, strategy.anchorPairs);
	AnchorSetStrategy(name, strategy.setVerb);
	if strategy.reverseSetVerb then
		ReverseAnchorSetStrategy(name,
			strategy.reverseSetVerb,
			strategy.setVerb);
	end;
	EdgeSetStrategy(name, strategy.setVerb);
	StackStrategy(name, strategy.defaultAnchor);
	CenterStackStrategy(name);

	strategy.reverseJustify = strategy.reverseJustify or {};
	JustifyStrategy(name, strategy.reverseJustify, strategy.defaultAnchor);
	CenterJustifyStrategy(name, strategy.reverseJustify);
end;

-- Tweak some default functions for least-surprise usage.
Anchors.FlipTop   =Anchors.VFlipTop;
Anchors.FlipBottom=Anchors.VFlipBottom;

Anchors.FlipLeft =Anchors.HFlipLeft;
Anchors.FlipRight=Anchors.HFlipRight;

function Anchors.Center(frame, ref)
	return Anchors.Share(frame, ref, "CENTER");
end;

function Anchors.Set(frame, anchor, ref, anchorTo, x, y)
	anchor=anchor:upper();
	anchorTo=anchorTo:upper();
	local region = GetAnchorable(frame, anchor);
	assert(Frames.IsRegion(region), "frame must be a frame. Got: "..type(region));
	ref=GetBounds(ref or region:GetParent(), anchorTo);
	assert(Frames.IsRegion(ref), "ref must be a frame. Got: "..type(ref));
	if DEBUG_TRACE then
		trace("%s:SetPoint(%q, %s, %q, %d, %d)",
			tostring(region),
			anchor,
			tostring(ref),
			anchorTo,
			x,
			y
		);
	end;
	region:SetPoint(anchor, ref, anchorTo, x, y);
end;

function Anchors.Clear(...)
	if select("#", ...) == 1 and #(...) > 0 then
		trace("Unpacking list for clearing")
		return Anchors.Clear(unpack(...));
	end;
	for i=1, select("#", ...) do
		local frame = select(i, ...);
		if frame then
			Frames.AsRegion(frame):ClearAllPoints();
		end;
	end;
end;

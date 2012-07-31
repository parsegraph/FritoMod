-- Anchors frames to one another.
--
-- Anchors provides many ways of anchoring frames to one another. It's
-- designed to be as powerful as possible for the client; the flipside
-- is the source here is rather complicated.
--
-- I've divided the functionality into Strategies and Modes. Each Mode
-- provides a different way of anchoring frames. Each Strategy is a
-- single way to anchor them.
--
-- ### MODES
--
-- Currently, the following modes are available:
--
-- #### FLIPPING MODES
--
-- Flipping modes align frames such that they are next to one another.
--
-- Horizontal (H)
-- Anchor frames along the horizontal axis. Corner anchors are aligned
-- horizontally, so you can align a series of frames using their topmost
-- points.
--
-- Vertical (V)
-- Anchor frames along the vertical axis. Corner anchors are aligned
-- vertically, so you can align a series of frames using their left- or
-- rightmost points.
--
-- Diagonal (D)
-- Anchor frames diagonally. This behaves similarly to Horizontal and
-- Vertical for sides (e.g. Left, Top, Right, or Bottom), but corners
-- will be aligned vertically; a series of frames will extend in a
-- diagonal direction from the first frame.
--
-- #### SHARING MODES
--
-- Sharing modes align frames such that they overlap one another.
--
-- ShareInner (S, Shared, Sharing)
-- Frame anchors will be overlapped. This will stack frames on top of
-- one another. Frame insets from backdrops will be respected, causing
-- frames to be stacked within their borders.
--
-- ShareOuter (OS, OuterShared, OuterSharing)
-- Frames will be stacked, similar to ShareInner. However, frame insets
-- are ignored, so frames will be aligned outside their borders.
--
-- ### COMMON ARGUMENTS
--
-- Unless otherwise specified, each function expects arguments in the following
-- order:

-- Anchors.%s(anchorable, anchor, bounds, gapX, gapy)

-- The anchorable may be either a region (or frame), or a UI object. If it's
-- the latter case, then the helper function GetAnchorable is used to deduce
-- a frame.

-- The anchor is the string specifying an anchor for the given anchorable. It
-- will be used to determined the anchorTo point based on the mode's logic. Some
-- strategies do not expect an anchor (the anchor is implied by the function name,
-- as in EdgeSetStrategy)

-- The bounds is used as the reference. Regions and frames are used directly. UI objects
-- will be converted to frames using the helper function GetBounds.

-- The gap should be specified in absolute terms. The sign will be determined
-- using the mode's strategy for aligning frames. For the most part, gap signs
-- will behave as expected.
--
-- ### STRATEGIES

-- The following strategies are available for the above modes. Each strategy
-- adds several functions to Anchors, available by combining the mode name with
-- the strategy. For example, the stacking strategy with the horizontal mode
-- would be Anchors.HStack ( "H" being the mode, and "Stack" being the
-- strategy).

-- All current strategies are described in brief below. Full documentation can
-- be found for each strategy.

-- #### AnchorSetStrategy

-- Aligns two frames using the specified anchor. For flipping modes, the
-- frames will be aligned next to each other, and for sharing modes, the
-- frames will be stacked on top of one another.

-- * Anchors.HAnchorTo, Anchors.HFlipFrom
-- * Anchors.VAnchorTo, Anchors.VFlipFrom
-- * Anchors.DAnchorTo, Anchors.DFlipFrom
-- * Anchors.ShareOuter
-- * Anchors.ShareInner

-- Anchors.HAnchorTo(f, "left", ref)
-- Anchors f's left anchor to ref.
-- +---+---+
-- |ref| f |
-- +---+---+

-- #### ReverseAnchorSetStrategy

-- Aligns two frames using the specified anchor. The specified frames will
-- be aligned next to each other.

-- * Anchors.HFlipOver, Anchors.HFlipTo, Anchors.HFlip
-- * Anchors.VFlipOver, Anchors.VFlipTo, Anchors.VFlip
-- * Anchors.DFlipOver, Anchors.DFlipTo, Anchors.DFlip

-- Anchors.HFlipOver(f, ref, "left");
-- Flips f over ref's left, aligning f to the left of ref.
-- +---+---+
-- | f |ref|
-- +---+---+

-- #### EdgeSetStrategy

-- Aligns two frames using several anchors, collectively called an edge.
-- Flipping anchors will be aligned next to one another, sharing the specified
-- edge. Sharing anchors will be overlapped using the specified edge.

-- * Anchors.HAnchorToLeft
-- * Anchors.VAnchorToLeft
-- * Anchors.DAnchorToLeft
-- * Anchors.ShareLeft
-- * Anchors.ShareOuterLeft

-- Each of the above is also available for the following edges:

-- * Left (topleft, topright)
-- * Right (topright, bottomright)
-- * Top (topleft, topright)
-- * Bottom (bottomleft, bottomright)
-- * All (left, right, top, bottom)
-- * Orthogonal (left, right, top, bottom)
-- * Verticals (top, bottom)
-- * Horizontals (left, right)

-- #### StackStrategy

-- Aligns a series of frames in order. For flipping modes, the frames will
-- be arranged linearly. For sharing modes, the frames will be stacked on
-- top of one another.

-- * Anchors.HStack%s
-- * Anchors.VStack%s
-- * Anchors.DStack%s
-- * Anchors.SStack%s, Anchors.SharedStack%s
-- * Anchors.OSStack%s, Anchors.OuterSharedStack%s

-- ##### Anchors.%sStackTo

-- The frames will be stacked in the specified anchor direction. For example,
-- Anchors.DStackTo("topright", a, b, c) will stack frames in the topright direction,
-- with the last frame becoming the reference frame.

-- local ref = Anchors.HStackTo("right", a, b, c)
-- +---+---+---+
-- | a>| b>| c |
-- +---+---+---+

-- ##### Anchors.%sStackFrom

-- The frames will be stacked similarly to StackTo. However, the first rather than
-- last frame will become the reference frame.

-- local ref = Anchors.HStackFrom("right", a, b, c)
-- +---+---+---+
-- | a |<b |<c |
-- +---+---+---+

-- #### CenterStackStrategy

-- * Anchors.HCStack
-- * Anchors.VCStack
-- * Anchors.CStack

-- Stacks a series of frames in the specified direction, similar to StackStrategy.
-- However, the middle-most frame will become the reference frame.

-- local ref = Anchors.HCStack("right", a, b, c)
-- +---+---+---+
-- | a>| b |<c |
-- +---+---+---+

-- #### JustifyStrategy

-- The frames will be arranged in order, similar to stack. However, the visible
-- order will always match the argument order; the frames will never appear "reverse"

-- Internally, StackStrategy is used to implement justified frames.

-- * Anchors.HJustify%s
-- * Anchors.VJustify%s
-- * Anchors.DJustify%s

-- local ref = Anchors.HJustifyTo("left", a, b, c)
-- +---+---+---+
-- | a |<b |<c |
-- +---+---+---+

-- local ref = Anchors.HJustifyFrom("left", a, b, c)
-- +---+---+---+
-- | a>| b>| c |
-- +---+---+---+

-- #### CJustifyStrategy

-- Justifies a series of frames, similar to JustifyStrategy. However, the central
-- frame will be used as the reference frame. The visible order is identical to
-- JustifyStrategy.

-- local ref = Anchors.HCJustify("right", a, b, c)
-- +---+---+---+
-- | a>| b |<c |
-- +---+---+---+
-- assert(ref == b);

-- local ref = Anchors.HCJustify("left", a, b, c)
-- +---+---+---+
-- | a>| b |<c |
-- +---+---+---+
-- assert(ref == b);

if nil ~= require then
	require "wow/Frame-Layout";
	require "wow/Frame-Container";
	require "fritomod/Strings";
	require "fritomod/Metatables";
end;

Anchors={};

DEBUG_TRACE_ANCHORS = false;

local gtrace = trace;
local function trace(...)
	if DEBUG_TRACE_ANCHORS then
		return gtrace(...);
	end;
end;

-- Converts passed anchor arguments into a canonical form. Anchors allows
-- clients to omit some arguments when it is convenient to do so. I wanted
-- these conversions to be shared across Anchors functions, so this function
-- was written to ensure the conversion is consistent.
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
	if type(gap) == "table" and Frames.AsRegion(gap) then
		frames={gap, ...};
		gap=0;
	elseif select("#", ...) == 0 and type(gap) == "table" then
		if Frames.AsRegion(gap) then
			frames = {gap}
		else
			frames = gap;
		end;
		gap=0;
	elseif select("#", ...) == 1 and not Frames.AsRegion(...) then
		frames = ...;
	else
		frames={...};
	end;
	assert(type(gap) == "number", "Gap must be a number");
	return gap, frames;
end;

-- Insert the specified function into the Anchors table. If format is itself
-- a table, then each entry within format will be used. If name is a table, then
-- each name will also be inserted.
--
-- format (if it is a string) is a format string that will be interpolated
-- using name. This interpolation will serve as the name used within Anchors.
--
-- The curried function will be the value to the interpolated name.
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

-- Returns the canonical mode name for the given mode. By convention, the
-- first name within name is the "full" name. (e.g, "Horizontal" for the "H"
-- mode).
local function CanonicalModeName(name)
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

-- A strategy for anchoring frames using the mode's pairing strategy. Flipping
-- modes will cause the two frames to be aligned next to one another. Sharing
-- modes will cause the two frames to be stack on top of one another, with the
-- specified anchor determining where the frames are aligned.  All modes will
-- cause the paired anchors to touch (assuming no gap is specified)

-- Anchors.HFlipFrom(f, "topright", ref) causes f to be flipped over its topright
-- anchor.
-- +---+---+
-- | f |   |
-- +---|ref|
--     |   |
--     +---+
--
--see
--	ReverseAnchorSetStrategy
local function AnchorSetStrategy(name, setVerb, anchorSet)
	if type(setVerb) == "table" then
		for i=1, #setVerb do
			AnchorSetStrategy(name, setVerb[i], anchorSet);
		end;
		return;
	end;

	local mode = CanonicalModeName(name);
	local AnchorPair = Anchors[mode.."AnchorPair"];

	InjectIntoAnchors(setVerb, name, function(frame, ...)
		local AnchorSet = Anchors[anchorSet];
		assert(IsCallable(AnchorSet), "AnchorSet is not callable");
		local anchor, ref, x, y=GetAnchorArguments(frame, ...);
		local anchorTo = AnchorPair(anchor);
		assert(anchorTo, "Frames cannot be "..mode.." aligned using the "..anchor.." anchor");
		return AnchorSet(frame, anchor, ref, anchorTo, x, y);
	end);
end;

-- A strategy for anchoring frames using the mode's pairing strategy. This
-- will produce the same set of results as AnchorSetStrategy. However, the
-- anchor pairs are "reversed".

-- For example, the following two lines of code will produce the same result:
-- Anchors.HAnchorTo(f, "topright", ref) causes f to be flipped over its topright
-- anchor.
-- Anchors.HFlipOver(f, ref, "topleft") causes f to be flipped over ref's topleft
-- anchor.
-- +---+---+
-- | f |   |
-- +---|ref|
--     |   |
--     +---+

-- It is up to the client's preference which method is preferred. I personally
-- prefer the reverse anchor strategy.

--see
--	AnchorSetStrategy
local function ReverseAnchorSetStrategy(name, setVerb, reversingVerb, anchorSet)
	if type(setVerb) == "table" then
		for i=1, #setVerb do
			ReverseAnchorSetStrategy(name, setVerb[i], reversingVerb, anchorSet);
		end;
		return;
	end;

	local mode = CanonicalModeName(name);
	local AnchorPair = Anchors[mode.."AnchorPair"];

	if type(reversingVerb) == "table" then
		reversingVerb = reversingVerb[1];
	end;

	InjectIntoAnchors(
		setVerb,
		name,
		function(frame, ...)
			local AnchorSet = Anchors[anchorSet];
			assert(IsCallable(AnchorSet), "AnchorSet is not callable");
			local anchor, ref, x, y=GetAnchorArguments(frame, ...);
			local anchorTo = AnchorPair(anchor);
			assert(anchorTo, "No anchor pair found for "..mode.." set: "..anchor);
			return AnchorSet(frame, anchorTo, ref, anchor, x, y);
		end
	);
end;

-- A strategy that sets multiple anchors using the AnchorSetStrategy for the
-- specified mode. This will change the size of the anchoring frame if it
-- differs from the size of the reference frame.
--
-- Anchors.HFlipFromLeft(f, ref)
-- +---+---+
-- |   |   |
-- |ref| f |
-- |   |   |
-- +---+---+
--
-- Anchors.ShareLeft(f, ref)
-- +---+---+
-- | f :   |
-- |and:ref|
-- |ref:   |
-- +---+---+
--
-- I personally only use this strategy for sharing modes.
local function EdgeSetStrategy(name, setVerb)
	local mode = CanonicalModeName(name);

	if type(setVerb) == "table" then
		for i=1, #setVerb do
			EdgeSetStrategy(name, setVerb[i]);
		end;
		return;
	end;
	local SetPoint = Anchors[setVerb:format(mode)];

	local function FlipEdge(...)
		local anchors = {...};
		return function(frame, ref, x, y)
			for i=1, #anchors do
				SetPoint(frame, anchors[i], ref, x, y);
			end;
			return ref;
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
	InjectIntoAnchors({setVerb.."Orthogonal", setVerb.."Orthogonals"},
		name,
		FlipEdge("LEFT", "RIGHT", "TOP", "BOTTOM")
	);
	InjectIntoAnchors({setVerb.."Diagonal", setVerb.."Diagonals"},
		name,
		FlipEdge("TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT")
	);
	InjectIntoAnchors({setVerb.."Vertical", setVerb.."Verticals"},
		name,
		FlipEdge("TOP", "BOTTOM")
	);
	InjectIntoAnchors({setVerb.."Horizontal", setVerb.."Horizontals"},
		name,
		FlipEdge("LEFT", "RIGHT")
	);
end;

-- A strategy for lining up a series of frames.
--
-- local ref = Anchors.HStackTo("right", a, b, c)
-- +---+---+---+
-- | a>| b>| c |
-- +---+---+---+
-- For StackTo, the last frame is always the reference frame.
--
-- local ref = Anchors.HStackFrom("right", a, b, c)
-- +---+---+---+
-- | a |<b |<c |
-- +---+---+---+
-- For StackFrom, the first frame is always the reference frame.
--
-- The mode will determine the anchor pairs used for a given anchor.
--
-- Use this if you want to align a series of frames, but don't care about
-- the visible ordering. I rarely use Stack over Justify, since it's very
-- common to expect the visible ordering of frames to be preserved.
local function StackStrategy(name, defaultAnchor)
	local mode = CanonicalModeName(name);

	if type(setVerb) == "table" then
		setVerb = setVerb[1];
	end;
	local FlipOver = Anchors[mode.."FlipOver"];
	local AnchorPair = Anchors[mode.."AnchorPair"];

	local function Stack(towardsFirst, anchor, ...)
		assert(type(anchor) == "string", "Anchor must be a string, but was a " .. type(anchor));
		assert(select("#", ...) > 0, "At least one argument must be given");
		anchor=anchor:upper();
		if anchor == "CENTER" and defaultAnchor then
			local CStack = Anchors[mode.."CStack"];
			return CStack(defaultAnchor, ...);
		end;
		local gap, frames = GetGapAndFrames(...);
		assert(#frames > 0, "At least one frame must be given");
		for i=1, #frames do
			assert(frames[i], "Frame #"..i.." must not be falsy");
		end;
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
			FlipOver(first, second, anchor, thisGap);
		end);
	end
	InjectIntoAnchors({
			"%sStack",
			"%sStackTo"
		},
		name,
		Curry(Stack, false)
	);

	local AnchorPair = Anchors[CanonicalModeName(name) .. "AnchorPair"];

	InjectIntoAnchors(
		"%sStackFrom",
		name,
		Curry(Stack, true)
	);
end;

-- A strategy for "lining up" a series of frames, ensuring the middle frame
-- is always the reference frame.
--
-- local ref = Anchors.HCStack("right", a, b, c)
-- +---+---+---+
-- | a>| b |<c |
-- +---+---+---+
--
-- local ref = Anchors.HCStack("left", a, b, c)
-- +---+---+---+
-- | c>| b |<a |
-- +---+---+---+
--
-- It's possible to specify a frame you'd like to become the reference frame, while preserving
-- the visible order of the stack:
--
-- local ref = Anchors.HCStack(b, "right", a, b, c, d)
-- +---+---+---+---+
-- | a>| b |<c |<d |
-- +---+---+---+---+
--
-- Specify a reference frame from a series of frames is useful when you want to be precise in
-- how centrally-aligned UI objects line up. Of course, if you just want the middle frame, then
-- you're free to omit the reference frame.
--
-- You can also specify the frame by index. These two calls are equivalent:
--
-- Anchors.HCStack(2, "right", a, b, c, d)
-- Anchors.HCStack(b, "right", a, b, c, d)
--
-- The visible order of the frames will match the ordering produced by StackTo,
-- however the anchoring will always place the middle frame as the reference
-- frame.
--
-- Personally, I rarely use CStack directly. It's more often used as a result of
-- CJustify. You can also implicitly run CStack by passing "CENTER" to Stack, assuming
-- the mode supports this.
local function CenterStackStrategy(name)
	local mode = CanonicalModeName(name);
	local StackFrom = Anchors[mode.."StackFrom"];
	local StackTo = Anchors[mode.."StackTo"];

	InjectIntoAnchors({
			"%sCStack",
			"%sCenterStack",
		},
		name,
		function(anchorOrMid, ...)
			local mid, anchor, gap, frames;
			if type(anchorOrMid) ~= "string" then
				-- We were given an explicit middle frame, so use it
				mid = anchorOrMid;
				anchor = select(1, ...);
				gap, frames = GetGapAndFrames(select(2, ...));
				if type(mid) ~= "number" then
					local oldMid = mid;
					mid = Lists.IndexOf(frames, mid);
					assert(mid, "Reference frame was not found in provided frames: "..tostring(oldMid));
				elseif mid < 0 then
					-- We were given a negative index, so loop around. -1 should refer to the last item
					-- in the list.
					local oldMid = mid;
					mid = #frames + mid + 1;
					assert(mid > 0 and mid <= #frames, "Reference index is out of range: "..tostring(oldMid));
				else
					assert(mid > 0, "Zero index is not allowed");
				end;
			else
				-- We were only given an anchor, so choose the middle frame.
				anchor = anchorOrMid;
				gap, frames = GetGapAndFrames(...);
				local count = #frames;
				if count % 2 == 0 then
					-- We have an even number of frames, so
					-- we need to pick one arbitrarily to be
					-- the "middle".
					mid = count / 2;
				else
					mid = (count + 1) / 2;
				end;
			end;
			assert(type(anchor) == "string", "Anchor must be a string, but was a " .. type(anchor));
			anchor=anchor:upper();
			-- Align the leading and trailing slices
			StackTo(  anchor, gap, Lists.Slice(frames, 1,   mid    ));
			StackFrom(anchor, gap, Lists.Slice(frames, mid, #frames));
			-- Return the reference frame
			return frames[mid];
		end
	);
end;

-- A strategy for lining up a series of frames, with the ordering of frames
-- always matching the ordering of the arguments. This allows you to keep
-- the visible arrangement of frames consistent, while ensuring you can safely
-- anchor to the specified anchor without overlapping the stack's content.
--
-- local ref = Anchors.HJustify("left", a, b, c)
-- +---+---+---+
-- | a |<b |<c |
-- +---+---+---+
--
-- local ref = Anchors.HJustify("right", a, b, c)
-- +---+---+---+
-- | a>| b>| c |
-- +---+---+---+
--
-- Observe how the specified ordering is preserved in the visible ordering
-- of the frames. This differs from StackTo:
--
-- local ref = Anchors.HStackTo("left", a, b, c)
-- +---+---+---+
-- | c |<b |<a |
-- +---+---+---+
--
-- local ref = Anchors.HStackTo("right", a, b, c)
-- +---+---+---+
-- | a>| b>| c |
-- +---+---+---+
--
-- Use justify when you always want the visible ordering to be in a specified
-- order, regardless of where the frames are aligned. The frames will be aligned
-- lexicographically, with left-to-right and top-to-bottom being preferred.
--
-- Internally, Justify uses Stack to actually arrange the frames. This means that there's
-- nothing you can do with Justify that you can't do with Stack. However, Justify is
-- typically what you want. If you need to work with more complicated arrangements, you'll
-- have to mess with anchor pairs and/or StackFrom.
--
-- There's a second form of Justify, called JustifyFrom. It was intended to be analogous
-- to StackFrom, but it's usually just very confusing to use since it's "backwards" from
-- what you'd expect. Specifically, the anchor specified to JustifyFrom will be opposite
-- of the actual reference frame. This usually results in UI bugs.
--
-- The only time I use JustifyFrom is if I'm doing something programmatically and don't
-- want to deal with anchor pairs. As you might imagine, this is very rare. My advice is
-- to forget about JustifyFrom unless you're working with a very unusual UI scenario.
local function JustifyStrategy(name, reverseJustify, defaultAnchor)
	local mode = CanonicalModeName(name);
	local AnchorPair = Anchors[mode.."AnchorPair"];

	local StackTo = Anchors[mode.."StackTo"];
	local StackFrom = Anchors[mode.."StackFrom"];

	InjectIntoAnchors({
			"%sJustify",
			"%sJustifyTo"
		},
		name,
		function(anchor, ...)
			assert(type(anchor) == "string", "Anchor must be a string, but was a " .. type(anchor));
			anchor=anchor:upper();
			if anchor == "CENTER" and defaultAnchor then
				local CJustify = Anchors[mode.."CJustify"];
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
			assert(type(anchor) == "string", "Anchor must be a string, but was a " .. type(anchor));
			anchor=anchor:upper();
			if anchor == "CENTER" and defaultAnchor then
				local CJustify = Anchors[mode.."CJustify"];
				return CJustify(defaultAnchor, ...);
			end;
			if reverseJustify[anchor] then
				return StackTo(AnchorPair(anchor), ...);
			end;
			return StackFrom(anchor, ...);
		end
	);
end;

-- Justifies a series of frames, with the central frame being used as
-- the reference. This will produce visibily identical results to Justify,
-- but the central frame will be used as the reference frame in all cases.
--
-- Anchors.HCJustify("right", a, b, c)
-- +---+---+---+
-- | a>| b |<c |
-- +---+---+---+
--
-- Anchors.HCJustify("left", a, b, c)
-- +---+---+---+
-- | a>| b |<c |
-- +---+---+---+
--
-- When CJustify is used, many specified anchors can produce the same result.
-- For example, for HCJustify, "right" and "left" produce identical results:
-- the frames are aligned such that their centers are vertically aligned.  If
-- "topright" or "topleft" are given, then the topmost anchors are vertically
-- aligned.
--
-- I use CJustify when I want to perform two alignments. I want to vertically
-- align a series of UI objects. Each UI object is comprised of a number of
-- horizontally-aligned regions. I want the UI objects to be vertically aligned
-- using a central axis. Such an alignment is shown below:
--
--    Foo [ ] Onyxia
-- Edward [ ] Ragnaros
--   Karl [ ] Nefarian
--
-- In this case, each UI object (a line comprised of two names and an icon) must
-- be centrally stacked. I don't want the visible order to change, so I use justify.
-- The following code is called within UI object:
--
-- Anchors.HCJustify("right", sourceName, icon, targetName)
--
-- If the center, left, or right frame is not the one that you want to align with, you
-- can specify it explicitly to CJustify. Assume the following UI:
--
-- 60 [x] Foo [=====   ]
--
-- CJustify would attempt to align on the "Foo" text, which may be undesirable. Instead, we
-- want to align using the x (which I will call classIcon):
--
-- Anchors.HCJustify(classIcon, "right", levelText, classIcon, name, healthBar);
--
-- Returning to our example, I want each UI object to be vertically aligned, so
-- I need a stack or a justify.  I also want the visible ordering to be
-- consistent, regardless of whether I use the first or the last frame as the
-- reference for the whole list, so I need to use justify.
--
-- local ref = Anchors.VJustify("top", foo, edward, karl);
-- assert(ref == foo, "foo is the reference frame");
--
-- If you wanted to have the bottom frame become the reference, you would specify a bottom
-- anchor. The exact anchor specified will affect where each UI object lines up. If you
-- wanted the middle or some other frame to become the reference, then you could use CJustify
-- to do so.
local function CenterJustifyStrategy(name, reverseJustify)
	local mode = CanonicalModeName(name);
	local AnchorPair = Anchors[mode.."AnchorPair"];
	local CStack = Anchors[mode.."CStack"];

	local function GetAnchor(anchor)
		assert(type(anchor) == "string", "Anchor must be a string, but was a " .. type(anchor));
		return anchor:upper();
	end;

	InjectIntoAnchors({
			"%sCJustify",
			"%sCenterJustify",
			"%sCJustifyTo",
			"%sCenterJustifyTo",
		},
		name,
		function(anchorOrMid, ...)
			local anchor;
			if type(anchorOrMid) == "string" then
				-- No mid provided, so just pass directly to CStack
				anchor = GetAnchor(anchorOrMid);
				if reverseJustify[anchor] then
					return CStack(AnchorPair(anchor), ...);
				end;
				return CStack(anchor, ...);
			else
				local mid = anchorOrMid;
				anchor = GetAnchor(...);
				if reverseJustify[anchor] then
					return CStack(mid, AnchorPair(anchor), select(2, ...));
				end;
				return CStack(mid, anchor, select(2, ...));
			end;
		end
	);
end;

function Anchors.CalculateGap(anchor, ref, anchorTo, x, y)
	local insets;
	if ref ~= nil then
		insets = Frames.Insets(ref);
	else
		insets = {
			left = 0,
			right = 0,
			top = 0,
			bottom = 0
		};
	end;
	if x == nil and y == nil then
		x = 0;
		y = 0;
	elseif x == nil then
		assert(y ~= nil);
		x = 0;
	elseif y == nil then
		assert(x ~= nil);
		-- Y is allowed to be nil.
	else
		assert(x ~= nil);
		assert(y ~= nil);
	end;

	anchor=tostring(anchor):upper();
	anchorTo=tostring(anchorTo):upper();

	-- Remember that, in WoW, gap values are NOT relative to the anchors.
	-- Positive X gaps are towards the right side of the screen
	-- Positive Y gaps are towards the top side of the screen

	if anchor == "CENTER" or anchorTo == "CENTER" then
		y = y or 0;
	elseif anchor == "TOPLEFT" then
		if anchorTo == "TOPLEFT" then
			-- Frame shares ref's topleft
			if y == nil then
				y = x;
			end;
			x = x + insets.left;
			y = y + insets.top;
			y = -y;
		elseif anchorTo == "TOP" then
			-- Frame shares ref's top edge
			if y == nil then
				y = x;
				x = 0;
			end;
			y = y + insets.top;
			y = -y;
		elseif anchorTo == "TOPRIGHT" then
			-- Frame is horizontally flipped over ref's right edge
			if y == nil then
				y = 0;
			end;
		elseif anchorTo == "RIGHT" then
			-- Frame is horizontally flipped over ref's right edge
			if y == nil then
				y = 0;
			end;
		elseif anchorTo == "BOTTOMRIGHT" then
			-- Frame is diagonally flipped over ref's bottomright corner
			if y == nil then
				y = x;
			end;
			y = -y;
		elseif anchorTo == "BOTTOM" then
			-- Frame is flipped over ref's bottom edge
			if y == nil then
				y = x;
				x = 0;
			end;
			y = -y;
		elseif anchorTo == "BOTTOMLEFT" then
			-- Frame is vertically flipped over ref's bottomleft corner
			if y == nil then
				y = x;
				x = 0;
			end;
			y = -y;
			x = -x;
		elseif anchorTo == "LEFT" then
			-- Frame is inside ref's left
			if y == nil then
				y = 0;
			end;
			x = x + insets.left;
		else
			error("Invalid anchorTo: "..tostring(anchorTo));
		end;
	elseif anchor == "TOP" then
		if anchorTo == "TOP" then
			-- Frame shares ref's top edge
			if y == nil then
				y = x;
				x = 0;
			end;
			y = y + insets.top;
			y = -y;
		elseif anchorTo == "TOPRIGHT" then
			-- Frame is horizontally centered on ref's right edge
			if y == nil then
				y = x;
				x = 0;
			end;
		elseif anchorTo == "RIGHT" then
			-- Frame is horizontally centered on ref's right edge
			if y == nil then
				y = x;
				x = 0;
			end;
		elseif anchorTo == "BOTTOMRIGHT" then
			-- Frame is horizontally centered on ref's right edge
			if y == nil then
				y = x;
				x = 0;
			end;
			y = -y;
		elseif anchorTo == "BOTTOM" then
			-- Frame is vertically flipped over ref's bottom edge
			if y == nil then
				y = x;
				x = 0;
			end;
			y = -y;
		elseif anchorTo == "BOTTOMLEFT" then
			-- Frame is horizontally centered on ref's left edge
			if y == nil then
				y = x;
				x = 0;
			end;
			x = -x;
			y = -y;
		elseif anchorTo == "LEFT" then
			-- Frame is horizontally centered on ref's left edge
			if y == nil then
				y = 0;
			end;
			x = -x;
		elseif anchorTo == "TOPLEFT" then
			-- Frame is horizontally centered on ref's left edge
			if y == nil then
				y = x;
				x = 0;
			end;
			x = -x;
		else
			error("Invalid anchorTo: "..tostring(anchorTo));
		end;
	elseif anchor == "TOPRIGHT" then
		if anchorTo == "TOPRIGHT" then
			-- Frame shares ref's topright
			if y == nil then
				y = x;
			end;
			x = x + insets.right;
			x = -x;
			y = y + insets.top;
			y = -y;
		elseif anchorTo == "RIGHT" then
			-- Frame shares ref's right edge
			if y == nil then
				y = 0;
			end;
			x = x + insets.right;
			x = -x;
		elseif anchorTo == "BOTTOMRIGHT" then
			-- Frame is vertically flipped over ref's bottom edge
			if y == nil then
				y = x;
				x = 0;
			end;
			y = -y;
		elseif anchorTo == "BOTTOM" then
			-- Frame is vertically flipped over ref's bottom edge
			if y == nil then
				y = x;
				x = 0;
			end;
			y = -y;
		elseif anchorTo == "BOTTOMLEFT" then
			-- Frame is diagonally flipped over ref's bottomleft corner
			if y == nil then
				y = x;
			end;
			x = -x;
			y = -y;
		elseif anchorTo == "LEFT" then
			-- Frame is horizontally flipped over ref's left edge
			if y == nil then
				y = 0;
			end;
			x = -x;
		elseif anchorTo == "TOPLEFT" then
			-- Frame is horizontally flipped over ref's left edge
			if y == nil then
				y = 0;
			end;
			x = -x;
		elseif anchorTo == "TOP" then
			-- Frame is inside ref's top edge
			if y == nil then
				y = x;
				x = 0;
			end;
			y = y + insets.top;
			y = -y;
		else
			error("Invalid anchorTo: "..tostring(anchorTo));
		end;
	elseif anchor == "RIGHT" then
		if anchorTo == "RIGHT" then
			-- Frame shares ref's right edge
			if y == nil then
				y = 0;
			end;
			x = x + insets.right;
			x = -x;
		elseif anchorTo == "BOTTOMRIGHT" then
			-- Frame is vertically centered on ref's bottom edge
			if y == nil then
				y = 0;
			end;
			y = -y;
		elseif anchorTo == "BOTTOM" then
			-- Frame is vertically centered on ref's bottom edge
			if y == nil then
				y = 0;
			end;
			y = -y;
		elseif anchorTo == "BOTTOMLEFT" then
			-- Frame is vertically centered on ref's bottom edge
			if y == nil then
				y = 0;
			end;
			x = -x;
		elseif anchorTo == "LEFT" then
			-- Frame is horizontally flipped over ref's left edge
			if y == nil then
				y = 0;
			end;
			x = -x;
		elseif anchorTo == "TOPLEFT" then
			-- Frame is vertically centered on ref's top edge
			if y == nil then
				y = 0;
			end;
			x = -x;
		elseif anchorTo == "TOP" then
			-- Frame is vertically centered on ref's top edge
			if y == nil then
				y = 0;
			end;
		elseif anchorTo == "TOPRIGHT" then
			-- Frame is vertically centered on ref's top edge
			if y == nil then
				y = 0;
			end;
		else
			error("Invalid anchorTo: "..tostring(anchorTo));
		end;
	elseif anchor == "BOTTOMRIGHT" then
		if anchorTo == "BOTTOMRIGHT" then
			-- Frame shares ref's bottomright
			if y == nil then
				y = x;
			end;
			x = x + insets.right;
			x = -x;
			y = y + insets.bottom;
		elseif anchorTo == "BOTTOM" then
			-- Frame shares ref's bottom edge
			if y == nil then
				y = x;
				x = 0;
			end;
			y = y + insets.bottom;
		elseif anchorTo == "BOTTOMLEFT" then
			-- Frame is horizontally flipped over ref's left edge
			if y == nil then
				y = 0;
			end;
			x = -x;
			y = -y;
		elseif anchorTo == "LEFT" then
			-- Frame is horizontally flipped over ref's left edge
			if y == nil then
				y = 0;
			end;
			x = -x;
		elseif anchorTo == "TOPLEFT" then
			-- Frame is diagonally flipped over ref's topleft corner
			if y == nil then
				y = x;
			end;
			x = -x;
		elseif anchorTo == "TOP" then
			-- Frame is vertically flipped over ref's top edge
			if y == nil then
				y = x;
				x = 0;
			end;
		elseif anchorTo == "TOPRIGHT" then
			-- Frame is vertically flipped over ref's top edge
			if y == nil then
				y = x;
				x = 0;
			end;
		elseif anchorTo == "RIGHT" then
			-- Frame shares ref's right edge
			if y == nil then
				y = 0;
			end;
			x = x + insets.right;
			x = -x;
		else
			error("Invalid anchorTo: "..tostring(anchorTo));
		end;
	elseif anchor == "BOTTOM" then
		if anchorTo == "BOTTOM" then
			-- Frame shares ref's bottom edge
			if y == nil then
				y = x;
				x = 0;
			end;
			y = y + insets.bottom;
		elseif anchorTo == "BOTTOMLEFT" then
			-- Frame is horizontally centered on ref's left edge
			if y == nil then
				y = x;
				x = 0;
			end;
			x = -x;
			y = -y;
		elseif anchorTo == "LEFT" then
			-- Frame is horizontally centered on ref's left edge
			if y == nil then
				y = x;
				x = 0;
			end;
			x = -x;
		elseif anchorTo == "TOPLEFT" then
			-- Frame is horizontally centered on ref's left edge
			if y == nil then
				y = x;
				x = 0;
			end;
			x = -x;
		elseif anchorTo == "TOP" then
			-- Frame is vertically flipped over ref's top edge
			if y == nil then
				y = x;
				x = 0;
			end;
		elseif anchorTo == "TOPRIGHT" then
			-- Frame is horizontally centered on ref's right edge
			if y == nil then
				y = x;
				x = 0;
			end;
		elseif anchorTo == "RIGHT" then
			-- Frame is horizontally centered on ref's right edge
			if y == nil then
				y = 0;
			end;
		elseif anchorTo == "BOTTOMRIGHT" then
			-- Frame is horizontally centered on ref's right edge
			if y == nil then
				y = x;
				x = 0;
			end;
			y = -y;
		else
			error("Invalid anchorTo: "..tostring(anchorTo));
		end;
	elseif anchor == "BOTTOMLEFT" then
		if anchorTo == "BOTTOMLEFT" then
			-- Frame shares ref's bottomleft corner
			if y == nil then
				y = x;
			end;
			x = x + insets.left;
			y = y + insets.bottom;
		elseif anchorTo == "LEFT" then
			-- Frame shares ref's left edge
			if y == nil then
				y = 0;
			end;
			x = x + insets.left;
		elseif anchorTo == "TOPLEFT" then
			-- Frame is vertically flipped over ref's top edge
			if y == nil then
				y = x;
				x = 0;
			end;
			x = -x;
		elseif anchorTo == "TOP" then
			-- Frame is vertically flipped over ref's top edge
			if y == nil then
				y = x;
				x = 0;
			end;
		elseif anchorTo == "TOPRIGHT" then
			-- Frame is diagonally flipped over ref's topright corner
			if y == nil then
				y = x;
			end;
		elseif anchorTo == "RIGHT" then
			-- Frame is horizontally flipped over ref's right edge
			if y == nil then
				y = 0;
			end;
		elseif anchorTo == "BOTTOMRIGHT" then
			-- Frame is horizontally flipped over ref's right edge
			if y == nil then
				y = 0;
			end;
			y = -y;
		elseif anchorTo == "BOTTOM" then
			-- Frame shares ref's bottom edge
			if y == nil then
				y = x;
				x = 0;
			end;
			y = y + insets.bottom;
			y = -y;
		else
			error("Invalid anchorTo: "..tostring(anchorTo));
		end;
	elseif anchor == "LEFT" then
		if anchorTo == "LEFT" then
			-- Frame shares ref's left edge
			if y == nil then
				y = 0;
			end;
			x = x + insets.left;
		elseif anchorTo == "TOPLEFT" then
			-- Frame is vertically centered on ref's top edge
			if y == nil then
				y = 0;
			end;
			x = -x;
		elseif anchorTo == "TOP" then
			-- Frame is vertically centered on ref's top edge
			if y == nil then
				y = 0;
			end;
		elseif anchorTo == "TOPRIGHT" then
			-- Frame is vertically centered on ref's top edge
			if y == nil then
				y = 0;
			end;
		elseif anchorTo == "RIGHT" then
			-- Frame is horizontally flipped over ref's right edge
			if y == nil then
				y = 0;
			end;
		elseif anchorTo == "BOTTOMRIGHT" then
			-- Frame is vertically centered on ref's bottom edge
			if y == nil then
				y = 0;
			end;
			y = -y;
		elseif anchorTo == "BOTTOM" then
			-- Frame is vertically centered on ref's bottom edge
			if y == nil then
				y = 0;
			end;
		elseif anchorTo == "BOTTOMLEFT" then
			-- Frame is vertically centered on ref's bottom edge
			if y == nil then
				y = 0;
			end;
			x = -x;
		else
			error("Invalid anchorTo: "..tostring(anchorTo));
		end;
	elseif anchorTo == "EXAMPLE_ANCHOR" then
		-- I have this final case here to ensure I know what criteria I'm resolving
		-- whenever I start messing with the above if-statements
		if anchorTo == "EXAMPLE_REF_ANCHOR" then
			-- What's the visual relationship?
			if y == nil then
				-- What does a one-arg gap mean?
			end;
			-- What direction does the x push?
			-- What direction does the y push?
		end;
	else
		error("Invalid anchor: "..tostring(anchor));
	end;

	--[[if insets.top > 0 and Strings.StartsWith(anchor, "TOP") then
		y=y+insets.top;
	elseif insets.bottom > 0 and Strings.StartsWith(anchor, "BOTTOM") then
		y=y-insets.bottom;
	end;
	if insets.left > 0 and Strings.EndsWith(anchor, "LEFT") then
		x=x+insets.left;
	elseif insets.right > 0 and Strings.EndsWith(anchor, "RIGHT") then
		x=x-insets.right;
	end;]]
	return x, y;
end;

local modes = {};

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

modes.Horizontal = {
	name = {"Horizontal", "H"},
	anchorPairs = {
		TOPLEFT	= "TOPRIGHT",
		BOTTOMLEFT = "BOTTOMRIGHT",
		LEFT	   = "RIGHT"
	},
	setVerb = { "%sAnchorTo", "%sFlipFrom" },
	reverseSetVerb = { "%sFlipTo", "%sFlip", "%sFlipOver" },
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

modes.Vertical = {
	name = {"Vertical", "V"},
	anchorPairs = {
		BOTTOMRIGHT = "TOPRIGHT",
		BOTTOMLEFT  = "TOPLEFT",
		BOTTOM	  = "TOP"
	},
	setVerb = { "%sAnchorTo", "%sFlipFrom" },
	reverseSetVerb = { "%sFlipTo", "%sFlip", "%sFlipOver" },
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

modes.Diagonal = {
	name = {
		"Diagonal",
		"D",
		""
	},
	anchorPairs = {
		TOP	  = "BOTTOM",
		RIGHT	= "LEFT",
		TOPLEFT  = "BOTTOMRIGHT",
		TOPRIGHT = "BOTTOMLEFT",
	},
	setVerb = { "%sAnchorTo", "%sFlipFrom" },
	reverseSetVerb = { "%sFlipTo", "%sFlip", "%sFlipOver" },
	reverseJustify = {
		TOP = true,
		TOPLEFT = true,
		LEFT = true,
		BOTTOMLEFT = true,
	},
	defaultAnchor = "RIGHT"
};

modes.ShareInner = {
	name = {
		"Shared",
		"Sharing",
		"S",
	},
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

modes.ShareOuter = setmetatable({
		name = {
			"OuterShared",
			"OuterSharing",
			"OS"
		},
		setVerb = "ShareOuter",
		setAnchor = "OSet"
	}, {
		__index = modes.ShareInner
});

for _, strategy in pairs(modes) do
	local name = strategy.name;
	AnchorPairStrategy(name, strategy.anchorPairs);
	strategy.anchorSet = strategy.anchorSet or "Set";
	AnchorSetStrategy(name, strategy.setVerb, strategy.anchorSet);
	if strategy.reverseSetVerb then
		ReverseAnchorSetStrategy(name,
			strategy.reverseSetVerb,
			strategy.setVerb,
			strategy.anchorSet);
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

function Anchors.Center(frame, ...)
	return Anchors.Share(frame, "CENTER", ...);
end;

local function DoSet(useInner, frame, anchor, ref, anchorTo, x, y)
	local origRef = ref;
	if type(anchor) == "table" and #anchor > 0 then
		-- If we're given tables for both, assume they're meant to be used in tandem.
		if type(anchorTo) == "table" and #anchorTo > 0 then
			assert(#anchor == #anchorTo, "Anchor sizes must align");
			for i=1, #anchor do
				DoSet(useInner, frame, anchor[i], ref, anchorTo[i], x, y);
			end;
			return;
		end;
		for i=1, #anchor do
			DoSet(useInner, frame, anchor[i], ref, anchorTo, x, y);
		end;
		return;
	end;
	anchor=anchor:upper();
	if anchorTo and type(anchorTo) == "table" and #anchorTo > 0 then
		for i=1, #anchorTo do
			DoSet(useInner, frame, anchor, ref, anchorTo[i], x, y);
		end;
		return;
	end;
	if not anchorTo then
		anchorTo = anchor;
	end;
	anchorTo=anchorTo:upper();
	local region = GetAnchorable(frame, anchor);
	assert(Frames.IsRegion(region), "frame must be a frame. Got: "..type(region));
	ref=GetBounds(ref or region:GetParent(), anchorTo);
	assert(Frames.IsRegion(ref), "ref must be a frame. Got: "..type(ref));
	if useInner then
		x, y = Anchors.CalculateGap(anchor, ref, anchorTo, x, y);
	else
		x, y = Anchors.CalculateGap(anchor, nil, anchorTo, x, y);
	end;
	if DEBUG_TRACE_ANCHORS then
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
	return ref;
end;

Anchors.OuterSet = Curry(DoSet, false);
Anchors.OSet = Anchors.OuterSet;

Anchors.InnerSet = Curry(DoSet, true);
Anchors.ISet = Anchors.InnerSet;
Anchors.Set = Anchors.InnerSet;

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

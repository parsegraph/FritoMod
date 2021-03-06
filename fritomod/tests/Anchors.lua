if nil ~= require then
	require "wow/api/Frame";
	require "fritomod/Frames";
end;
local Suite=CreateTestSuite("fritomod.Anchors");

local function PointTest(runner, expectedPoints)
	return function(self)
		local ref = CreateFrame("Frame");
		local f = CreateFrame("Frame");
		expectedPoints = runner(f, ref);
		if #expectedPoints == 0 and expectedPoints.ref then
			expectedPoints = {expectedPoints};
		end;
		local points = Frames.DumpPointsToList(f);
		Assert.Equals(#expectedPoints, #points);
		for i=1, #expectedPoints do
			local expected = expectedPoints[i];
			local actual = points[i];
			Assert.Equals(
				expected, actual,
				"Anchor "..i.." must match expected anchor"
			);
		end;
	end;
end;

local function PointMapTest(runner, expectedPoints)
	return function(self)
		local ref = CreateFrame("Frame");
		local f = CreateFrame("Frame");
		expectedPoints = runner(f, ref);
		local points = Frames.DumpPointsToMap(f);
		Assert.Equals(expectedPoints, points, "Anchors must match");
	end;
end;

function Suite:TestGapReturnsSensibleValues()
	Assert.Equals({2, -2}, {Anchors.CalculateGap("topleft", nil, "topleft", 2)});
end;

Suite.TestSharingAnchorsCausesThemToOverlap = PointTest(
	function(f, ref)
		Anchors.Share(f, ref, "topleft");
		return {
			frame = f,
			ref = ref,
			anchor = "TOPLEFT",
			anchorTo = "TOPLEFT",
			x = 0,
			y = 0
		};
end);

Suite.TestAnchorsCanBeFlipped = PointTest(
	function(f, ref)
		Anchors.DiagonalFlip(f, ref, "topleft");
		return {
			frame = f,
			ref = ref,
			anchor = "BOTTOMRIGHT",
			anchorTo = "TOPLEFT",
			x = 0,
			y = 0
		};
end);

Suite.TestVerticalAnchorsStayInVerticalOrder = PointTest(
	function(f, ref)
		Anchors.VerticalFlip(f, ref, "topleft");
		return {
			frame = f,
			ref = ref,
			anchor = "BOTTOMLEFT",
			anchorTo = "TOPLEFT",
			x = 0,
			y = 0
		};
end);

Suite.TestVerticalAnchorsUseGapOnlyInVerticalDirection = PointTest(
	function(f, ref)
		Anchors.VerticalFlip(f, ref, "topleft", 2);
		return {
			frame = f,
			ref = ref,
			anchor = "BOTTOMLEFT",
			anchorTo = "TOPLEFT",
			x = 0,
			y = 2
		};
end);

Suite.TestVerticalBottomFlipWithGap = PointTest(
	function(f, ref)
		Anchors.VerticalFlip(f, ref, "bottomleft", 2);
		return {
			frame = f,
			ref = ref,
			anchor = "TOPLEFT",
			anchorTo = "BOTTOMLEFT",
			x = 0,
			y = -2
		};
end);

Suite.TestDiagonalLeftFlipWithGap = PointTest(
	function(f, ref)
		Anchors.DiagonalFlip(f, ref, "left", 2);
		return {
			frame = f,
			ref = ref,
			anchor = "RIGHT",
			anchorTo = "LEFT",
			x = -2,
			y = 0
		};
end);

Suite.TestDiagonalRightFlipWithGap = PointTest(
	function(f, ref)
		Anchors.DiagonalFlip(f, ref, "right", 2);
		return {
			frame = f,
			ref = ref,
			anchor = "LEFT",
			anchorTo = "RIGHT",
			x = 2,
			y = 0
		};
end);

Suite.TestDiagonalBottomFlipWithGap = PointTest(
	function(f, ref)
		Anchors.DiagonalFlip(f, ref, "bottom", 2);
		return {
			frame = f,
			ref = ref,
			anchor = "TOP",
			anchorTo = "BOTTOM",
			x = 0,
			y = -2
		};
end);

Suite.TestDiagonalFlipFromWithGap = PointTest(
	function(f, ref)
		Anchors.DiagonalFlipFrom(f, ref, "bottom", 2);
		return {
			frame = f,
			ref = ref,
			anchor = "BOTTOM",
			anchorTo = "TOP",
			x = 0,
			y = 2
		};
end);

Suite.TestShareAllSetsAllFourDirections = PointMapTest(function(f, ref)
		Anchors.ShareAll(f, ref);
		return {
			BOTTOM = {
				frame = f,
				ref = ref,
				anchor = "BOTTOM",
				anchorTo = "BOTTOM",
				x = 0,
				y = 0
			},
			TOP = {
				frame = f,
				ref = ref,
				anchor = "TOP",
				anchorTo = "TOP",
				x = 0,
				y = 0
			},
			LEFT = {
				frame = f,
				ref = ref,
				anchor = "LEFT",
				anchorTo = "LEFT",
				x = 0,
				y = 0
			},
			RIGHT = {
				frame = f,
				ref = ref,
				anchor = "RIGHT",
				anchorTo = "RIGHT",
				x = 0,
				y = 0
			}
		};
end);

Suite.TestShareAllAndShareInteractHappily = PointMapTest(function(bounds, ref)
		local a = CreateFrame("Frame", nil, ref);
		local b = CreateFrame("Frame", nil, ref);
		Anchors.Flip(b, a, "RIGHT");
		Anchors.ShareAll(bounds, a);
		Anchors.Share(bounds, b, "RIGHT");
		return {
			BOTTOM = {
				frame = bounds,
				ref = a,
				anchor = "BOTTOM",
				anchorTo = "BOTTOM",
				x = 0,
				y = 0
			},
			TOP = {
				frame = bounds,
				ref = a,
				anchor = "TOP",
				anchorTo = "TOP",
				x = 0,
				y = 0
			},
			LEFT = {
				frame = bounds,
				ref = a,
				anchor = "LEFT",
				anchorTo = "LEFT",
				x = 0,
				y = 0
			},
			RIGHT = {
				frame = bounds,
				ref = b,
				anchor = "RIGHT",
				anchorTo = "RIGHT",
				x = 0,
				y = 0
			}
		};
end);

function Suite:TestStack()
	local frames = {};
	for i=1, 5 do
		table.insert(frames, CreateFrame("Frame"));
	end;
	local f = Anchors.HStack("topleft", frames);
	assert(Frames.AsRegion(f), "Stack must return an object convertible to a region");
end;

function Suite:TestJustify()
	local frames = {};
	for i=1, 5 do
		table.insert(frames, CreateFrame("Frame"));
	end;
	local f = Anchors.HJustify("topleft", frames);
	assert(Frames.AsRegion(f), "Justify must return an object convertible to a region");
end;

function Suite:TestCenterJustify()
	local frames = {};
	for i=1, 5 do
		table.insert(frames, CreateFrame("Frame"));
	end;
	Anchors.HCenterJustify("topleft", frames);
end;

function Suite:TestClear()
    local f = Frames.New();
    Anchors.Center(f);
    Assert.Equals(1, f:GetNumPoints());
    Anchors.Clear(f);
    Assert.Equals(0, f:GetNumPoints());
end;

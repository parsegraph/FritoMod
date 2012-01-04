if nil ~= require then
	require "wow/api/Frame";
	require "fritomod/Frames";
end;
local Suite=CreateTestSuite("fritomod.Anchors");

function Suite:ShouldIgnore()
	return not WoW;
end;

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

if nil ~= require then
	require "fritomod/OOP-Class";
	require "fritomod/Lists";
	require "fritomod/Assert";
	require "fritomod/Tables";

	require "wow/Frame";
end;

local Frame = WoW.Frame;

Frame:AddConstructor(function(self)
	self.points = {};
	self.pointOrder = {};
end);

function Frame:Raise()
	trace("STUB Frame:Raise");
end;

function Frame:Lower()
	trace("STUB Frame:Lower");
end;

function Frame:SetFrameStrata()
	trace("STUB Frame:SetFrameStrata");
end;

function Frame:GetEffectiveScale()
	return 1;
end;

function Frame:SetAllPoints(ref)
	ref = ref or self:GetParent();
	assert(ref, "Frame must have a reference frame when setting all points");
	self:SetPoint("TOPLEFT", ref);
	self:SetPoint("BOTTOMRIGHT", ref);
end;

function Frame:SetPoint(anchor, ...)
	WoW.AssertAnchor(anchor);
	if select("#", ...) == 0 then
		-- SetPoint(anchor)
		return self:SetPoint(anchor, nil, anchor, 0, 0);
	elseif select("#", ...) == 1 then
		local ref = ...;
		return self:SetPoint(anchor, ref, anchor, 0, 0);
	elseif select("#", ...) == 2 then
		local first, second = ...;
		if type(first) == "number" and type(second) == "number" then
			-- SetPoint(anchor, x, y)
			return self:SetPoint(anchor, nil, anchor, ...);
		else
			-- SetPoint(anchor, ref, anchorTo)
			return self:SetPoint(anchor, first, second, 0, 0);
		end;
	end;
	assert(
		select("#", ...) == 4,
		"Invalid number of arguments. Given: "..select("#", ...)
	);
	local ref, anchorTo, x, y = ...;
	ref = ref or self:GetParent();
	if type(ref) == "string" then
		ref = _G[ref];
	end;
	assert(Frames.IsRegion(ref), "Reference frame must be a frame");
	WoW.AssertAnchor(anchorTo, "anchorTo must be a valid anchor name");
	anchor=anchor:upper();
	anchorTo=anchorTo:upper();
	Assert.Number(x, "X offset must be a number");
	Assert.Number(y, "Y offset must be a number");
	self:GetDelegate("layout"):SetPoint(anchor, ref, anchorTo, x, y);
end;

function Frame:ClearAllPoints(ref)
	self.points = {};
	self.pointOrder = {};
end;

function Frame:SetPoint(anchor, ref, anchorTo, x, y)
	self.points[anchor] = {
		frame = self,
		anchor = anchor,
		ref = ref,
		anchorTo = anchorTo,
		x = x,
		y = y
	};
	Lists.RemoveAll(self.pointOrder, anchor);
	table.insert(self.pointOrder, anchor);
end;

function Frame:GetPoint(index)
	Assert.Number(index, "index must be a number");
	local anchorName = self.pointOrder[index];
	assert(anchorName, "index must not be out of range. Given: "..tostring(index));
	local anchor = self.points[anchorName];
	assert(
		anchor,
		"Anchor not found for anchor name: "..tostring(anchorName)
	);
	return anchor.anchor,
		anchor.ref,
		anchor.anchorTo,
		anchor.x,
		anchor.y
end;

function Frame:GetNumPoints()
	return #self.pointOrder;
end;

function Frame:SetWidth(width)
	self.width = width;
end;

function Frame:GetWidth()
	return self.width;
end;

function Frame:GetHeight()
	return self.height;
end;

function Frame:SetHeight(height)
	self.height = height;
end;

function Frame:GetCenter()
	return 0, 0;
end;

function Frame:GetLeft()
	return 0;
end;

function Frame:GetRight()
	return 0;
end;

function Frame:GetTop()
	return 0;
end;

function Frame:GetBottom()
	return 0;
end;

do
	local validAnchors = {
		"TOPLEFT", "TOP", "TOPRIGHT",
		"LEFT", "CENTER", "RIGHT",
		"BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT",
		"CENTERX", "CENTERY"
	};

	function WoW.AssertAnchor(anchor)
		assert(
			type(anchor)=="string",
			"Anchor must be a string. Given: " .. type(anchor)
		);
		anchor=anchor:upper();
		assert(
			Lists.Contains(validAnchors, anchor),
			"Anchor name is invalid. Given: "..anchor
		);
	end;
end;

-- vim: set noet :

if nil ~= require then
	require "fritomod/OOP-Class";
	require "fritomod/Lists";
	require "fritomod/Assert";
	require "fritomod/Tables";

	require "wow/Frame";
end;

local Frame = WoW.Frame;

do
	local validAnchors = {
		"TOPLEFT", "TOP", "TOPRIGHT",
		"LEFT", "CENTER", "RIGHT",
		"BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT",
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

WoW.Frame:AddConstructor(function(self)
	self.points = {};
	self.pointOrder = {};
end);

function Frame:SetAllPoints(ref)
	-- TODO Stub
end;

function Frame:SetPoint(anchor, ...)
	WoW.AssertAnchor(anchor);
	if select("#", ...) == 0 then
		-- SetPoint(anchor)
		return self:SetPoint(anchor, self.frame:GetParent(), anchor, 0, 0);
	elseif select("#", ...) == 2 then
		-- SetPoint(anchor, x, y)
		-- SetPoint(anchor, ref, anchorTo)
		local first, second = ...;
		if type(first) == "number" and type(second) == "number" then
			return self:SetPoint(anchor, self.frame:GetParent(), anchor, ...);
		else
			return self:SetPoint(anchor, first, second, 0, 0);
		end;
	end;
	assert(
		select("#", ...) == 4,
		"Invalid number of arguments. Given: "..select("#", ...)
	);
	local ref, anchorTo, x, y = ...;
	if type(ref) == "string" then
		ref = _G[ref];
	end;
	WoW.AssertFrame(ref);
	WoW.AssertAnchor(anchorTo);
	anchor=anchor:upper();
	anchorTo=anchorTo:upper();
	Assert.Number(x, "X offset must be a number");
	Assert.Number(y, "Y offset must be a number");
	self.points[anchor] = {
		frame = self.frame,
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

function Frame:Raise()
end;

function Frame:Lower()

end;

Box = FritoLib.OOP.Class(DisplayObjectContainer);
local Box = Box;

Box.defaultValues = {
	Direction = Box.VERTICAL;
}

Box.VERTICAL = "Vertical";
Box.HORIZONTAL = "Horizontal";

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function Box.prototype:init()
	Box.super.prototype.init(self);
end;

function Box:ToString()
	return "Box";
end;

-------------------------------------------------------------------------------
--
--  Getters and Setters
--
-------------------------------------------------------------------------------

StyleClient.AddComputedValue(Box.prototype, "Direction", StyleClient.CHANGE_SIZE);
StyleClient.AddComputedValue(Box.prototype, "Gap", StyleClient.CHANGE_SIZE);

-------------------------------------------------------------------------------
--
--  Overridden Methods: StyleClient
--
-------------------------------------------------------------------------------

function Box.prototype:FetchDefaultFromTable(valueName)
	return Box.defaultValues[valueName] or
		Box.super.prototype.FetchDefaultFromTable(self, valueName);
end;

-------------------------------------------------------------------------------
--
--  Overridden Methods: Invalidating
--
-------------------------------------------------------------------------------

function Box.prototype:Measure()
	Box.super.prototype.Measure(self);
	local direction = self:GetDirection();
	for child in self:Iter() do
		if direction == Box.HORIZONTAL then
			self.measuredWidth = self.measuredWidth + child:GetWidth();
			self.measuredHeight = max(self.measuredHeight, child:GetWidth());
		else
			self.measuredWidth = max(self.measuredWidth, child:GetWidth());
			self.measuredHeight = self.measuredHeight + child:GetHeight();
		end;
	end;
	local totalGap = self:GetGap() * (self:GetNumChildren() - 1);
	if direction == Box.HORIZOTNAL then
		self.measuredWidth = self.measuredWidth + totalGap;
	else
		self.measuredHeight = self.measuredHeight + totalGap;
	end;
end;

function Box.prototype:UpdateLayout(width, ehi

end;

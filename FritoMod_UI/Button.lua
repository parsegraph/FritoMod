Button = OOP.Class(DisplayObject);

function Button:Measure()
	self.measuredWidth = 64
	self.measuredHeight = 64
end;

function Button:Constructor()
	self.class.super.Constructor(self);
	self.listeners = {};
	function self:AddListener(func, ...)
		return Lists.Insert(self.listeners, Curry(func, ...));
	end;
end;

function Button:ConstructChildren()
	self.frame = CreateFrame("Button");
	self.frame:SetScript("OnClick", function()
		Lists.CallEach(self.listeners);
	end);
end;

local function ValidateSize(target)
	for i=1, #target do
		ValidateSize(target[i]);
	end;
    if target.invalidatedSize then
		target.invalidatedSize = false;
		local oldw,oldh=target.measuredWidth, target.measuredHeight;
		local w,h=target:Measure();
		target.measuredWidth,target.measuredHeight=w,h;
		if oldw ~= w or oldh ~= h then
			if target.parent then
				target.parent:InvalidateSize();
			end;
			target:InvalidateLayout();
		end;
	end;
end;

local function ValidateLayout(target)
    if target.invalidatedLayout then
        target.invalidatedLayout = false;
        target:UpdateLayout();
    end;
	for i=1, #target do
		ValidateLayout(target[i]);
	end;
end;

if not Mixins then
	Mixins = {};
end;

function Mixins.Validating(class)
	function class:InvalidateLayout()
		self.invalidatedLayout=true;
	end;

	function class:InvalidateSize()
		self.invalidatedSize=true;
	end;

	function class:ValidateNow()
		ValidateSize(self);
		ValidateLayout(self);
	end;

	class.UpdateLayout=Noop;
	class.Measure=Noop;
end;

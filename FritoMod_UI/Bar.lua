if nil ~= require then
	require "FritoMod_OOP/OOP-Class";
	require "FritoMod_UI/DisplayObject";
end;

Bar = OOP.Class(DisplayObject);

function Bar:ConstructChildren()
	self.frame = CreateFrame("Frame");
	self.group=self.frame:CreateAnimationGroup();
	local scale=self.group:CreateAnimation("scale");
	scale:SetOrigin("LEFT",0,0);
	scale:SetDuration(3);
	scale:SetScale(10,1);
end;

function Bar:SetTexture(texture)
	self.texture=texture;
	self:InvalidateLayout();
end;

function Bar:UpdateLayout()
	Bar.super.UpdateLayout(self);
	self.frame:SetBackdrop({
		bgFile = self.texture
	});
	self.group:Play();
end;

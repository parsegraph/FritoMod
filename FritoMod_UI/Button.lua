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

function Button:SetSpell(spell)
	self.spell=spell;
end;

function Button:SetTexture(texture)
	self.texture=texture;
end;

function Button:ConstructChildren()
	local b = CreateFrame("Button",nil,nil,"SecureActionButtonTemplate");
	b:HookScript("OnClick", function()
		Lists.CallEach(self.listeners);
	end);
	self.frame=b;
end;

function Button:UpdateLayout()
	local b=self.frame;
	Button.super.UpdateLayout(self);
	if self.texture then
		b:SetNormalTexture(self.texture);
		b:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square");
		b:SetPushedTexture("Interface/Buttons/UI-Quickslot-Depress");
	end;
	if self.spell then
		b:SetAttribute("type", "macro");
		b:SetAttribute("macrotext", "/cast " .. self.spell);
	end;
end;

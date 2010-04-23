if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_UI/TextField";
end;

local Suite = ReflectiveTestSuite:New("FritoMod_UI.TextField");
local s;
local keep;

Suite:AddListener(Metatables.Noop({
	TestStarted = function()
		s=Stage:GetInstance();
		s.frame = CreateFrame("Frame",nil,UIParent);
	end,
	TestFinished = function(self, suite)
		if not keep then
			s.frame:SetParent(nil);
		end;
		keep=nil;
	end
}));

function Suite:TestTextField()
	s:AddChild(TextField:New("Basekateer"));
	s:ValidateNow();
end;

function Suite:TestButton()
	local button = Button:New();
	button:AddListener(print, "Clicked!");
	button:SetTexture("Interface/Icons/Ability_Ambush");
	s:AddChild(button);
	s:ValidateNow();
end;

function Suite:TestNeatSpellbook()
	local vbox = Box:New();
	vbox:SetDirection("vertical");
	local spells,i,hbox={},1;
	while true do
		local spellName = GetSpellName(i, BOOKTYPE_SPELL)
		if not spellName then
			break;
		end
		if not spells[spellName] then
			spells[spellName] = true;
			if not hbox or hbox:GetNumChildren()>10 then
				hbox = Box:New();
				vbox:AddChild(hbox);
				i=0;
			end;
			local b=Button:New();
			b:SetSpell(spellName);
			b:SetTexture(GetSpellTexture(spellName));
			hbox:AddChild(b);
		end;
		i=i+1;
	end
	s:AddChild(vbox);
	s:ValidateNow();
end;

function Suite:TestBuffs()
	keep=true;
	local vbox = Box:New();
	vbox:SetDirection("vertical");
	local i=1;
	while true do
		local name, _, icon = UnitBuff("player", i);
		if not icon then
			break;
		end;
		local hbox=Box:New();
		local b=Button:New();
		b:SetTexture(icon);
		hbox:AddChild(b);
		hbox:SetAlignment("center");
		hbox:AddChild(TextField:New(name));
		vbox:AddChild(hbox);
		i=i+1;
	end;
	s:AddChild(vbox);
	s:ValidateNow();
end;

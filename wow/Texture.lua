if nil ~= require then
	require "wow/Frame";
	require "fritomod/OOP-Class";
end;

local Texture = OOP.Class(WoW.Frame);
WoW.Texture = Texture;

function WoW.Frame:CreateTexture()
	return Texture:New(self);
end;

function Texture:SetTexture(...)
    if select("#", ...) > 1 then
        self.color = {...};
        return;
    end;
    print("STUB SetTexture");
end;

function Texture:GetColor()
    return unpack(self.color);
end;

function Texture:GetTexture(...)
end;

function Texture:SetTexCoord(...)

end;

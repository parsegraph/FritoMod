if nil ~= require then
	require "wow/Frame";
	require "wow/Frame-Layer";
	require "fritomod/OOP-Class";
end;

local Texture = OOP.Class("WoW.Texture", WoW.Frame);
WoW.Texture = Texture;

if not WoW.GetFrameType("Texture") then
    WoW.RegisterFrameType("Texture", WoW.Texture);
end;

function WoW.Frame:CreateTexture()
	return Texture:New(self);
end;

function Texture:SetTexCoord(...)

end;

function Texture:SetColorTexture(...)
    if select("#", ...) > 1 then
        self.color = {...};
        return;
    end;
    trace("STUB SetTexture");
end;

function Texture:SetTexture(...)
    if select("#", ...) > 1 then
        self.color = {...};
        return;
    end;
    trace("STUB SetTexture");
end;

function Texture:GetTexture()
    if self.color then
        return self:GetColor();
    end;
end;

function Texture:GetColor()
    if self.color then
        return unpack(self.color);
    end;
end;

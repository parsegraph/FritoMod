if nil ~= require then
	require "wow/Frame";
	require "fritomod/OOP-Class";
end;

local Texture = OOP.Class(WoW.Frame);
WoW.Texture = Texture;

function Texture:ClassName()
    return "wow/Texture";
end;

WoW.RegisterFrameType("Texture", Texture);

function WoW.Frame:CreateTexture()
	return Texture:New(self);
end;

WoW.Delegate(Texture, "texture", {
    "GetTexture",
    "SetTexture",
    "GetColor"
});

local Delegate = OOP.Class();

function Texture:SetTexCoord(...)

end;

local Delegate = OOP.Class();

function Delegate:SetTexture(...)
    if select("#", ...) > 1 then
        self.color = {...};
        return;
    end;
    trace("STUB SetTexture");
end;

function Delegate:GetTexture()
    if self.color then
        return self:GetColor();
    end;
end;

function Delegate:GetColor()
    if self.color then
        return unpack(self.color);
    end;
end;

if not WoW.GetFrameDelegate("Texture", "texture") then
    WoW.SetFrameDelegate("Texture", "texture", Delegate, "New");
end;

Texture = FritoLib.OOP.Class(StyleClient, InvalidatingForwarder);
local Texture = Texture;

Texture.defaultValues = {
	BorderSize = 10,
	Inset = 3,
	Background = "Blizzard Tooltip",
	Border = "Blizzard Tooltip"
}

Texture.mediaKeyNames = {
	Background = "Background", 
	Border = "Border",
	BackgroundColor = "Color"
};

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function Texture.prototype:init()
	Texture.super.prototype.init(self);
end;

function Texture:ToString()
	return "Texture";
end;

-------------------------------------------------------------------------------
--
--  Layout Methods
--
-------------------------------------------------------------------------------

function Texture.prototype:ApplyTo(frame)
	frame = LayoutUtil:GetFrame(frame);
	local inset = self:GetInset();
	if not frame.SetBackdrop then
		error("Texture: The frame provided does not support textures: " .. tostring(displayObject));
	end;
	frame:SetBackdrop{
		bgFile = self:GetBackground(),
		edgeFile = self:GetBorder(),
		edgeSize = self:GetBorderSize(),
		insets = {
			left = inset, 
			right = inset, 
			top = inset, 
			bottom = inset
		}
	};
	frame:SetBackdropColor(unpack(self:GetBackgroundColor()));
end;

-------------------------------------------------------------------------------
--
--  Getters and Setters
--
-------------------------------------------------------------------------------

StyleClient.AddComputedValue(Texture.prototype, "Background", StyleClient.CHANGE_LAYOUT);
StyleClient.AddComputedValue(Texture.prototype, "Border", StyleClient.CHANGE_LAYOUT);
StyleClient.AddComputedValue(Texture.prototype, "BorderSize", StyleClient.CHANGE_SIZE);
StyleClient.AddComputedValue(Texture.prototype, "Inset", StyleClient.CHANGE_SIZE);
StyleClient.AddComputedValue(Texture.prototype, "BackgroundColor", StyleClient.CHANGE_LAYOUT);

-------------------------------------------------------------------------------
--
--  Overridden Methods: StyleClient
--
-------------------------------------------------------------------------------

function Texture.prototype:FetchDefaultFromTable(valueName)
	return Texture.defaultValues[valueName];
end;

function Texture.prototype:GetMediaKeyName(valueName)
	return Texture.mediaKeyNames[valueName];
end;



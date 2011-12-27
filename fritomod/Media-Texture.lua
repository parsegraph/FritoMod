if nil ~= require then
    require "fritomod/Media";
end;

local textures={};

textures.marble ="Interface/FrameGeneral/UI-Background-Marble";
textures.rock   ="Interface/FrameGeneral/UI-Background-Rock";
textures.gold   ="Interface/DialogFrame/UI-DialogBox-Gold-Background";
textures.black  ="Interface/DialogFrame/UI-DialogBox-Background";
textures.tooltip="Interface/Tooltips/UI-Tooltip-Background";
textures.chat   ="Interface/Tooltips/ChatBubble-Background";

Media.texture(textures);

do
    local coords = {12/64, 51/64, 12/64, 51/64};
    Media.texture(function(spell)
        local texture = select(3, GetSpellInfo(spell));
        return {
            name = texture,
            coords = coords
        };
    end);
end;

Media.SetAlias("texture", "textures", "background", "backgrounds");

Frames=Frames or {};
function Frames.Texture(f, texture)
    texture = Media.texture[texture];
    local coords;
    if type(texture) == "table" then
        coords = texture.coords;
        texture = texture.name;
    end;
    if f:GetObjectType():find("Button$") then
        f:SetNormalTexture(texture);
    elseif f:GetObjectType() == "Texture" then
        f:SetTexture(texture);
    else
        local t=f:CreateTexture();
        Anchors.ShareAll(t, f);
        t:SetTexture(texture);
        f=t;
    end;
    if coords then
        f:SetTexCoord(unpack(coords));
    end;
    return f;
end;

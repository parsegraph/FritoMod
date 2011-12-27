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

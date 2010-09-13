if nil ~= require then
    require "FritoMod_Media/Media";
end;

local SOUNDS_DIR = "Interface\\Addons\\FritoMod_Media\\sounds\\"
local SOUNDS={};
for _, v in ipairs({
    "onoes",
    "eep",
    "hello",
    "silenced",
}) do
    SOUNDS[v]=true;
end;

Media.sound = function(k)
    if SOUNDS[k] then
        return SOUNDS_DIR..sound_name..".wav";
    end;
end;

if nil ~= require then
    require "Media";
end;

local sounds={};
for _, v in ipairs({
    "onoes",
    "eep",
    "hello",
    "silenced",
}) do
    sounds[v]=("Interface\\Addons\\FritoMod_Media\\sounds\\%s.wav"):format(v);
end;

Media.sound(sounds);
Media.SetAlias("sound", "sounds", "wav", "mp3", "noises", "audio");

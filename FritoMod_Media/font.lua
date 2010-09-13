if nil ~= require then
    require "FritoMod_Functional/currying";

    require "FritoMod_Media/Media";
end;

Media.font = Curry(Media.SharedMedia, "font");
Media.font.default="Fonts\\FRIZQT__.TTF";

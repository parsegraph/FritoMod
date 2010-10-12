if nil ~= require then
    require "FritoMod_Functional/currying";

    require "FritoMod_Media/Media";
end;

local fonts={
    default="Fonts\\FRIZQT__.TTF",
    skurri="Fonts\\skurri.ttf",
    morpheus="Fonts\\MORPHEUS.ttf",
    arial="Fonts\\ARIALN.ttf",
    arialn="Fonts\\ARIALN.ttf",
};

fonts["Fritz Quadrata"]=fonts.default;
fonts.friz=fonts.default;
fonts.fritz=fonts.default;
fonts.frizqt=fonts.default;
fonts.fritzqt=fonts.default;
fonts.fritzqt=fonts.default;

Media.font(fonts);
Media.font(Curry(Media.SharedMedia, "font"));
Media.SetAlias("font", "fonts", "text", "fontface", "fontfaces");

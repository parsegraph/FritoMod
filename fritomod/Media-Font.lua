-- Sets up fonts for Media.font

if nil ~= require then
    require "fritomod/Frames";
    require "fritomod/currying";
    require "fritomod/Media";
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

function Frames.Text(parent, font, size, ...)
    local text;
    if type(parent) ~= "table" then
        text=parent;
        parent=UIParent:CreateFontString();
    end;
    if parent.CreateFontString then
        f=parent:CreateFontString();
        if Frames.IsInjected(parent) then
            Frames.Inject(f);
        end;
    else
        f=parent;
    end;
    if not font:match("\\") then
        font=Media.font[font];
    end;
    f:SetFont(font, size, ...);
    if text then
        f:SetText(text);
    end;
    return f;
end;

function Frames.Font(frame, font, size, ...)
    if not font:match("\\") then
        font=Media.font[font];
    end;
    if frame.GetFontString then
        frame=frame:GetFontString();
    end;
    if frame.SetFont then
        frame:SetFont(font, size, ...);
    end
    return f;
end;


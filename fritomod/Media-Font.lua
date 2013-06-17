-- Sets up fonts for Media.font

if nil ~= require then
    require "wow/FontString";

	require "fritomod/Frames";
	require "fritomod/currying";
	require "fritomod/Media";
end;

local fonts;
function Media.font.wowDelegate(name)
    if not fonts then
        local FRITOMOD="Interface/AddOns/FritoMod/media";

        fonts={
            default="Fonts\\FRIZQT__.TTF",
            skurri="Fonts\\skurri.ttf",
            morpheus="Fonts\\MORPHEUS.ttf",
            arial="Fonts\\ARIALN.ttf",
            arialn="Fonts\\ARIALN.ttf",
        };

        fonts.inconsolata = FRITOMOD.."/fonts/Inconsolata.ttf";
        fonts.consolas    = fonts.inconsolata;
        fonts.mono        = fonts.inconsolata;
        fonts.monospace   = fonts.inconsolata;

        fonts.veramono = FRITOMOD.."/fonts/VeraMono.ttf";

        fonts["Fritz Quadrata"]=fonts.default;
        fonts.friz=fonts.default;
        fonts.fritz=fonts.default;
        fonts.frizqt=fonts.default;
        fonts.fritzqt=fonts.default;
        fonts.fritzqt=fonts.default;
    end;
    local font = fonts[name];
    if font then
        return font:gsub("/", "\\");
    end;
end;

Media.font(function(name)
    if rawget(Media.font, "wowDelegate") then
        return rawget(Media.font, "wowDelegate")(name);
    end;
end);

Media.font(Curry(Media.SharedMedia, "font"));
Media.SetAlias("font", "fonts", "text", "fontface", "fontfaces");

local outlines = {
	[{
		"thick",
		"heavy",
		"bold"}] = "THICKOUTLINE",
	outline = "OUTLINE",
	[{
		"mono",
		"monochrome"}] = "MONOCHROME"
};
Tables.Expand(outlines);

function Frames.Text(parent, font, size, ...)
	font=font or "default";

    local fontstring;
	if not parent.CreateFontString then
        if Frames.AsRegion(parent) and Frames.AsRegion(parent).CreateFontString then
            fontstring=parent:CreateFontString();
        else
            fontstring = Frames.New("FontString", parent);
        end;
	end;
	if Frames.IsInjected(parent) then
		Frames.Inject(fontstring);
	end;
	if not font:match("\\") then
		font=Media.font[font];
	end;
	local color;
	local flags;
	for i=1, select("#", ...) do
		local option = tostring(select(i, ...)):lower();
		if outlines[option] then
			if flags then
				flags=flags..","..outlines[option];
			else
				flags=outlines[option];
			end;
		else
			color=Media.color[option];
		end;
	end;
	fontstring:SetFont(font, size, flags);
	if color then
		Frames.Color(fontstring, color);
	end;
	return fontstring;
end;

function Frames.Font(frame, font, size, ...)
	if not font:match("\\") then
		font=Media.font[font];
	end;
	frame=Frames.AsRegion(frame);
	if frame.GetFontString then
		frame=frame:GetFontString();
	end;
	if frame.SetFont then
		frame:SetFont(font, size, ...);
	end
	return f;
end;

function Frames.EditBox(...)
    local first = ...;
    local parent, font, size, style;
    if type(first) == "table" and Frames.AsRegion(first) then
        parent = first;
        font, size, style = select(2, ...);
    else
        parent = UIParent;
        font, size, style = ...;
    end;
    assert(parent);
    font = font or "friz";
    size = size or 12;
    local editBox = Frames.New("EditBox", parent);
    Frames.Font(editBox, font, size, style);
    editBox:SetAutoFocus(false);
    Callbacks.OnEscape(editBox, editBox, "ClearFocus");
    return editBox;
end;

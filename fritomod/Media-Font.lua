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
	local options = {...};
	local color;
	local flags;
	for i=1, #options do
		local option = options[i]:lower();
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
	f:SetFont(font, size, flags);
	if color then
		Frames.Color(f, color);
	end;
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


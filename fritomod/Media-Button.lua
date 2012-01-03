-- A collection of button textures, used with Frames.ButtonTexture.
--
-- Each value is a table containing textures to map a Button or CheckButton.
--
-- Ideally, virtual frames would make this sort of thing obsolete. Most of
-- this code is actually from virtual frames. However, Blizzard's virtual
-- frames usually carry a lot of unwanted baggage that we'd have to prune.
-- We also can't use virtual frames if our frame already exists. These two
-- problems necessitate some sort of Lua-based solution.
--
-- A conservative approach would be to work around the limitations. We'd provide
-- a factory for the virtual frames we want, with extra code to remove unwanted
-- baggage. This seems to only get us really weak code: we're still heavily
-- dependent on Blizzard's virtual frames. I also think the direction this
-- approach takes us is poor: we're not really writing anything powerful, just
-- "fixing bugs."
--
-- A pure approach would be to do nothing. Anything we write that uses virtual
-- frames will be competing with them. Our solution would be to basically say
-- "Write and use XML when you want to create complicated UIs." Since creating
-- complicated UIs is one of the biggest reasons for creating FritoMod, this
-- simply won't do.
--
-- I chose the bold approach. We steal the useful stuff that Blizzard gave us,
-- but we rewrite it in Lua. We get maximum power and flexibility, since it's
-- entirely our stuff. It also becomes natural to build complicate UIs, since
-- we can design our API to fit well with FritoMod.
--
-- In practice, the redundancy factor hasn't really been a problem. We usually
-- steal good ideas and fit them so FritoMod can do them easily. In other words,
-- we're learning from Blizzard's code and integrating it, rather than merely
-- copying it.
--
-- Of course, you can mix virtual frames with FritoMod all you want. I do this
-- when a virtual frame actually fits well with what I'm doing. However, this
-- happens less often than you'd think.
if nil ~= require then
	require "fritomod/Frames";
	require "fritomod/Media";
end;

local buttons={};

local function BlendHighlights(button)
	if button.GetHighlightTexture then
		button:GetHighlightTexture():SetBlendMode("ADD");
	end;
	if button.GetCheckedTexture then
		button:GetCheckedTexture():SetBlendMode("ADD");
	end;
end;

buttons.slot={
	normal		 ="Interface\\Buttons\\UI-Quickslot2",
	pushed		 ="Interface\\Buttons\\UI-Quickslot-Depress",
	highlight	  ="Interface\\Buttons\\ButtonHilight-Square",
	checked		="Interface\\Buttons\\CheckButtonHilight",
	Finish		 =function(button)
		if button.GetNormalTexture then
			local t=button:GetNormalTexture();
			-- Ensure the textures' visible portion fills the size.
			t:SetTexCoord(12/64, 51/64, 12/64, 51/64);
		end;
		BlendHighlights(button);
	end
};
buttons.default=buttons.slot;

local function ApplyStandardButton(layout, button)
	if button:GetObjectType():find("Button$") then
		button:SetNormalTexture(layout.normal);
		button:SetPushedTexture(layout.pushed);
		button:SetHighlightTexture(layout.highlight);
		if button:GetObjectType():find("CheckButton$") then
			button:SetCheckedTexture(layout.checked);
			button:SetDisabledCheckedTexture(layout.disabledChecked);
		end;
	elseif button:GetObjectType() == "Texture" then
		button:SetTexture(layout.normal);
	else
		local t=button:CreateTexture();
		t:SetAllPoints();
		t:SetTexture(layout.normal);
		button=t;
	end;
	if layout.Finish then
		layout.Finish(button, layout);
	end;
	return button;
end;

local function StandardButton(name, layout)
	if not layout then
		layout={};
	end;
	layout.normal		 =name.."-Up";
	layout.pushed		 =name.."-Down";
	layout.highlight	  =name.."-Highlight";
	Metatables.Callable(layout, function(layout, button)
		ApplyStandardButton(layout, button);
		BlendHighlights(button);
	end);
	return layout;
end;

local function StandardCheckButton(name, layout)
	layout=StandardButton(name, layout);
	layout.checked=name.."-Check";
	layout.disabledChecked=name.."-Check-Disabled";
	return layout;
end;

local function AdjustTexCoords(layout, texture)
	local topEdge   =layout.dimensions.top;
	local leftEdge  =layout.dimensions.left;
	local rightEdge =layout.dimensions.right;
	local bottomEdge=layout.dimensions.bottom;

	local textureWidth =layout.textureWidth;
	local textureHeight=layout.textureHeight;

	if texture then
		texture:SetTexCoord(
			leftEdge/textureWidth, rightEdge/textureWidth,
			topEdge/textureHeight, bottomEdge/textureHeight
		);
	end;
end;

buttons.check=StandardCheckButton("Interface/Buttons/UI-CheckBox");
buttons.close=StandardButton("Interface/Buttons/UI-Panel-MinimizeButton", {
	dimensions={
		left=6,
		right=25,
		top=7,
		bottom=25
	},
	textureWidth=32,
	textureHeight=32
});
Metatables.OverloadCallable(buttons.close, function(layout, button)
	AdjustTexCoords(layout, button:GetNormalTexture());
	AdjustTexCoords(layout, button:GetPushedTexture());
	AdjustTexCoords(layout, button:GetDisabledTexture());

	return button;
end);

local function HorizontalFixedButton(name, layout)
	layout.normal   =name.."-Up";
	layout.pushed   =name.."-Down";
	layout.highlight=name.."-Highlight";

	assert(layout.textureWidth, "textureWidth must be provided");
	assert(layout.textureHeight, "textureWidth must be provided");

	if layout.dimensions then
		layout.dimensions.left  =layout.dimensions.left   or 0;
		layout.dimensions.right =layout.dimensions.right  or layout.textureWidth;
		layout.dimensions.top   =layout.dimensions.top	or 0;
		layout.dimensions.bottom=layout.dimensions.bottom or layout.textureHeight;
	end;

	setmetatable(layout, {
		__call=function(self, button)
			local leftSlice =layout.slices.left;
			local rightSlice=layout.slices.right;

			local topEdge   =layout.dimensions.top;
			local leftEdge  =layout.dimensions.left;
			local rightEdge =layout.dimensions.right;
			local bottomEdge=layout.dimensions.bottom;

			local textureWidth =layout.textureWidth;
			local textureHeight=layout.textureHeight;

			local left  =button:CreateTexture();
			local right =button:CreateTexture();
			local center=button:CreateTexture();

			Anchors.ShareLeft(left);
			Anchors.ShareRight(right);
			Anchors.HFlipLeft(center, right);
			Anchors.HFlipRight(center, left);

			left  :SetWidth(leftSlice);
			right :SetWidth(rightSlice);

			left  :SetTexture(layout.normal);
			right :SetTexture(layout.normal);
			center:SetTexture(layout.normal);

			left  :SetDrawLayer("BORDER");
			right :SetDrawLayer("BORDER");
			center:SetDrawLayer("BACKGROUND");

			left:SetTexCoord(
				leftEdge/textureWidth, (leftEdge+leftSlice)/textureWidth,
				topEdge/textureHeight,  bottomEdge/textureHeight
			);

			right:SetTexCoord(
				(rightEdge-rightSlice)/textureWidth, rightEdge/textureWidth,
				topEdge/textureHeight,  bottomEdge/textureHeight
			);

			center:SetTexCoord(
				(leftEdge+leftSlice)/textureWidth, (rightEdge-rightSlice)/textureWidth,
				topEdge/textureHeight,  bottomEdge/textureHeight
			);

			button:SetHighlightTexture(layout.highlight);

			Callbacks.MouseDown(button, function()
				left  :SetTexture(layout.pushed);
				right :SetTexture(layout.pushed);
				center:SetTexture(layout.pushed);
				return function()
					left  :SetTexture(layout.normal);
					right :SetTexture(layout.normal);
					center:SetTexture(layout.normal);
				end;
			end);

			if layout.Finish then
				layout.Finish(button, layout, left, right, center);
			end;
		end
	});

	return layout;
end;

buttons.dialog=HorizontalFixedButton("Interface/Buttons/UI-DialogBox-Button", {
	slices={
		left=8,
		right=8,
	},
	dimensions={
		bottom=23
	},
	textureWidth=128,
	textureHeight=32,
});
function buttons.dialog.Finish(button, layout, left, right, center)
	local ht=button:GetHighlightTexture();
	ht:SetBlendMode("ADD");
	ht:SetAlpha(.75);
	ht:SetTexCoord(0, 1, 0, layout.dimensions.bottom/layout.textureHeight);

	local texCoords={center:GetTexCoord()};
	texCoords[5]=110/layout.textureWidth;
	texCoords[7]=texCoords[5];
	center:SetTexCoord(unpack(texCoords));
end;

Media.button(buttons);
Media.SetAlias("button", "buttons", "buttontexture");

Frames=Frames or {};

function Frames.ButtonTexture(button, layout)
	if type(layout)=="string" or not layout then
		layout=Media.button[layout];
	end;
	button=Frames.GetFrame(button);
	if IsCallable(layout) then
		layout(button);
	else
		ApplyStandardButton(button);
	end;
	return f;
end;
Frames.Button=Frames.ButtonTexture;


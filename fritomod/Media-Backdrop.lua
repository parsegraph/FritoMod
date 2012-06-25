if nil ~= require then
	require "fritomod/Tables";
	require "fritomod/Media";
	require "fritomod/Frames";

	require "wow/Frame-Container";
end;

local FRITOMOD="Interface/AddOns/FritoMod/media/";

local insets=setmetatable({
	dialog = { left = 11, right = 12, top = 12, bottom = 11 },
	slider = { left = 3,  right = 3,  top = 6,  bottom = 6  },
}, {
	__index=function(self, k)
		if type(k)=="number" then
			self[k]={
				left=k,
				right=k,
				top=k,
				bottom=k
			};
			return self[k];
		end;
	end
});

local backdrops=setmetatable({}, {
	__newindex=function(self, name, backdrop)
		-- Unix-style slashes work for Blizzard's textures, but not for
		-- custom addons. I like not having to type two characters, so
		-- we do the conversion here.
		backdrop.edgeFile=backdrop.edgeFile:gsub("/", "\\");
		if backdrop.bgFile then
			backdrop.bgFile=backdrop.bgFile:gsub("/", "\\");
		end;
		rawset(self, name, backdrop);
	end
});

backdrops.goldDialog={
	edgeFile="Interface/DialogFrame/UI-DialogBox-Gold-Border",
	bgFile  ="Interface/DialogFrame/UI-DialogBox-Gold-Background",
	edgeSize = 32,
	tile=true,
	tileSize=32,
	insets = insets.dialog
};
backdrops.gold=backdrops.goldDialog;

backdrops.blackdialog={
	edgeFile="Interface/DialogFrame/UI-DialogBox-Border",
	bgFile  ="Interface/DialogFrame/UI-DialogBox-Background",
	edgeSize = 32,
	tile=true,
	tileSize=32,
	insets = insets.dialog
};
backdrops.dialog=backdrops.blackdialog;
backdrops.black=backdrops.blackdialog;

backdrops.chatbubble={
	edgeFile="Interface/Tooltips/ChatBubble-Backdrop",
	bgFile  ="Interface/Tooltips/ChatBubble-Background",
	edgeSize = 32,
	tile=true,
	tileSize=32,
	insets = insets[32]
};
backdrops.chat=backdrops.chatbubble;

backdrops.tooltip={
	edgeFile="Interface/Tooltips/UI-Tooltip-Border",
	bgFile  ="Interface/Tooltips/UI-Tooltip-Background",
	edgeSize = 16,
	tile=true,
	tileSize=16,
	insets = insets[4]
};
backdrops.default=backdrops.tooltip;

backdrops.slider={
	edgeFile="Interface/Buttons/UI-SliderBar-Border",
	bgFile  ="Interface/Buttons/UI-SliderBar-Background",
	edgeSize=8,
	tile=true,
	tileSize=8,
	insets = insets.slider
};
backdrops.small=backdrops.slider;

backdrops.test={
	edgeFile=FRITOMOD.."Test-16-Border",
	bgFile  ="Interface/Buttons/UI-SliderBar-Background",
	edgeSize = 16,
	tile=true,
	tileSize=16,
	insets = insets[1]
};

backdrops.solid={
	edgeFile=FRITOMOD.."Solid-Border",
	bgFile  ="Interface/Buttons/UI-SliderBar-Background",
	edgeSize = 2,
	tile=true,
	tileSize=16,
	insets = insets[1]
};

do
	local sizes = {};
	Media.backdrop(function(size)
		if tonumber(size) then
			size=tonumber(size);
			if not sizes[size] then
				sizes[size]=Tables.Clone(backdrops.solid);
				sizes[size].edgeSize = size;
			end;
			return sizes[size];
		end;
	end);
end;

Media.backdrop(backdrops);
Media.SetAlias("backdrops", "border", "borders", "edge", "edges");

Frames=Frames or {};

function Frames.Backdrop(f, backdrop, bg)
	if type(backdrop)~="table" or not backdrop.edgeFile then
		backdrop=Media.backdrop[backdrop];
	end;
	if bg then
		local usedBackdrop=Tables.Clone(backdrop);
		usedBackdrop.bgFile=bg;
		backdrop=usedBackdrop;
	end;
	f=Frames.AsRegion(f);
	assert(f and f.SetBackdrop, "Provided object does not support backdrops");
	local insettedRegions = {};
	local oldInsets = Frames.Insets(f);
	do
		local regions = {f:GetRegions()};
		for _, region in ipairs(regions) do
			if Frames.IsInsetted(region, f) then
				trace("Found insetted region!");
				table.insert(insettedRegions, region);
			end;
		end;
	end;
	f:SetBackdrop(backdrop);
	Lists.Each(insettedRegions, Headless(Frames.AdjustInsets, f, oldInsets));
	return f;
end;


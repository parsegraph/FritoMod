if nil ~= require then
	require "fritomod/Media";
	require "fritomod/Tables";
end;

-- All keys to this table must be lowercase.
local textures={};

textures.marble ="Interface/FrameGeneral/UI-Background-Marble";
textures.rock   ="Interface/FrameGeneral/UI-Background-Rock";
textures.gold   ="Interface/DialogFrame/UI-DialogBox-Gold-Background";
textures.black  ="Interface/DialogFrame/UI-DialogBox-Background";
textures.tooltip="Interface/Tooltips/UI-Tooltip-Background";
textures.chat   ="Interface/Tooltips/ChatBubble-Background";

Media.texture(textures);

Media.texture(function(obj)
	if type(obj) == "table" then
		if obj.Texture then
			return obj:Texture();
		end;
		if obj.Icon then
			return obj:Icon();
		end;
	end;
end);

do
	local classTextures;
	Media.texture(function(targetClass)
		if type(targetClass) ~= "string" then
			return;
		end;
		if not classTextures then
			classTextures={};
			local name = "Interface/Glues/CharacterCreate/UI-CharacterCreate-Classes";
			for class, coords in pairs(CLASS_ICON_TCOORDS) do
				coords = Tables.Clone(coords);
				classTextures[class] = {
					name = name,
					coords = coords
				};
				local borderAdjustment = 4/256;
				coords[1] = coords[1] + borderAdjustment; -- Left border
				coords[2] = coords[2] - borderAdjustment; -- Right border
				coords[3] = coords[3] + borderAdjustment; -- Top border
				coords[4] = coords[4] - borderAdjustment; -- Bottom border
			end;
		end;
		targetClass=targetClass:upper();
		return classTextures[targetClass];
	end);
end;

do
	local coords = {12/64, 51/64, 12/64, 51/64};

	Media.spell(function(spell)
		local texture = select(3, GetSpellInfo(spell));
		if texture then
			return {
				name = texture,
				coords = coords
			};
		end;
	end);

	Media.SetAlias("spell", "ability", "cast", "action");

	Media.item(function(item)
		if type(item) ~= "number" then
			return;
		end;
		item = GetItemIcon(item);
		if item then
			return {
				name = item,
				coords = coords
			};
		end;
	end);

	Media.item(function(item)
		item = select(10, GetItemInfo(item));
		if item then
			return {
				name = item,
				coords = coords
			};
		end;
	end);

	Media.SetAlias("item", "icon", "loot", "drop", "treasure");

	Media.texture(function(name)
		if type(name) ~= "string" then
			return;
		end;
		name = name:lower();
		local spell = name:lower():match("^%s*s%a*%s*(%d+)%s*$");
		if spell then
			return Media.spell[tonumber(spell)];
		end;
		local item = name:lower():match("^%s*i%a*%s*(%d+)%s*$");
		if item then
			return Media.item[tonumber(item)];
		end;
	end);

	Media.texture(function(name)
		return Media.item[name] or Media.spell[name];
	end);
end;

Media.SetAlias("texture", "textures", "background", "backgrounds");

Frames=Frames or {};
function Frames.Texture(f, texture)
	f=Frames.GetFrame(f);
	texture = Media.texture[texture];
	local coords;
	if type(texture) == "table" then
		coords = texture.coords;
		texture = texture.name;
	end;
	if f:GetObjectType():find("Button$") then
		f:SetNormalTexture(texture);
	elseif f:GetObjectType() == "Texture" then
		f:SetTexture(texture);
	else
		local t=f:CreateTexture();
		Anchors.ShareAll(t, f);
		t:SetTexture(texture);
		f=t;
	end;
	if coords then
		f:SetTexCoord(unpack(coords));
	end;
	return f;
end;

-- Textures with coordinates.
--
-- coords must be specified as {left, right, top, bottom}
if nil ~= require then
	require "fritomod/Media";
	require "fritomod/Tables";
end;

-- Return a texture directly.
Media.texture(function(obj)
	if type(obj)=="table" and obj.name and obj.coords then
		return obj;
	end;
end);

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
		if obj.Value then
			return Media.texture[obj:Value()];
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

-- These are the texture coords for all Blizzard icons in Interface\Icons. There's
-- a few that deviate from this, but not by a noticeable amount. There's also a few
-- that are much larger (probably 256px or so), but the ratio is the same, so these
-- coordinates should work for those as well.
local ICON_COORDS = {4/64, 60/64, 4/64, 60/64};

Media.texture(function(texture)
	if type(texture)=="string" and texture:match("[/\\]") then
		if Strings.StartsWith(texture, "interface\\icons") then
			return {
				name = texture,
				coords = ICON_COORDS
			};
		else
			return texture;
		end;
	end;
end);

do
	local coords = ICON_COORDS;

	local namedIcons = {};

	namedIcons["melee swing"] ="Interface/ICONS/Ability_SteelMelee";
	namedIcons.swing = namedIcons["melee swing"];

	namedIcons.question = "Interface/ICONS/INV_Misc_QuestionMark";
	namedIcons["?"] = namedIcons.question;
	namedIcons.unknown = namedIcons.question;
	namedIcons["question mark"] = namedIcons.question;
	namedIcons["questionmark"] = namedIcons.question;
	namedIcons[""] = namedIcons.question;
	namedIcons.default = namedIcons.question;

	namedIcons.critter = "Interface/ICONS/ABILITY_SEAL";
	namedIcons.trivial = namedIcons.critter;

	namedIcons.mechanical = "Interface/ICONS/Ability_Mount_MechaStrider";

	local function HunterPetIcon(name, ...)
		namedIcons[name:lower()] = "Interface/ICONS/Ability_Hunter_Pet_"..name;
		for i=1, select("#", ...) do
			namedIcons[select(i, ...):lower()] = namedIcons[name:lower()];
		end;
	end;

	HunterPetIcon("Boar", "Pig");
	HunterPetIcon("Bear");
	HunterPetIcon("Lion", "Tiger", "Cat", "Tigress");
	HunterPetIcon("Chimera");
	HunterPetIcon("CoreHound", "Core Hound");
	HunterPetIcon("Gorilla", "Monkey");
	HunterPetIcon("Hyena");
	HunterPetIcon("Moth");
	HunterPetIcon("Owl");
	HunterPetIcon("Ravager");
	HunterPetIcon("Scorpid", "Scorpion");
	HunterPetIcon("DragonHawk", "Dragon Hawk");
	HunterPetIcon("Silithid");
	HunterPetIcon("Spider");
	HunterPetIcon("SporeBat", "Spore Bat");
	HunterPetIcon("TallStrider", "Strider");
	HunterPetIcon("Turtle", "Tortoise");
	HunterPetIcon("Wasp", "Insect");
	HunterPetIcon("WindSerpent", "Wind Serpent");
	HunterPetIcon("Worm");

	namedIcons.panther = "Interface/ICONS/Ability_Mount_BlackPanther";
	namedIcons.ram = "Interface/ICONS/Ability_Mount_MountainRam";
	namedIcons.kodo = "Interface/ICONS/Ability_Mount_Kodo_02";
	namedIcons.horse = "Interface/ICONS/Ability_Mount_NightmareHorse";
	namedIcons["kodo beast"] = namedIcons.kodo;

	namedIcons.wolf = "Interface/ICONS/Ability_Mount_WhiteDireWolf";
	namedIcons.coyote = namedIcons.wolf;

	namedIcons.tentacle = "Interface/ICONS/Achievement_Boss_YoggSaron_01";
	namedIcons.chicken = "Interface/ICONS/Spell_Magic_PolymorphChicken";
	namedIcons.rabbit = "Interface/ICONS/Spell_Magic_PolymorphRabbit";
	namedIcons.sheep = "Interface/ICONS/Spell_Nature_Polymorph";
	namedIcons.cow = "Interface/ICONS/Spell_Nature_Polymorph_Cow";
	namedIcons.skeleton = "Interface/ICONS/Spell_Shadow_RaiseDead";
	namedIcons.felhound = "Interface/ICONS/Spell_Shadow_SummonFelHunter";
	namedIcons["fel hound"] = namedIcons.felhound;
	namedIcons.felhunter = namedIcons.felhound;
	namedIcons["fel hunter"] = namedIcons.felhunter;
	namedIcons.imp = "Interface/ICONS/Spell_Shadow_SummonImp";
	namedIcons.succubus = "Interface/ICONS/Spell_Shadow_SummonSuccubus";

	namedIcons.dummy = "Interface/ICONS/Ability_Mount_RocketMount";
	namedIcons.targetdummy = namedIcons.dummy;
	namedIcons["target dummy"] = namedIcons.dummy;
	namedIcons["raider's target dummy"] = namedIcons.dummy;

	namedIcons.draenei = "Interface/ICONS/Achievement_Character_Draenei_Male";
	namedIcons.bloodelf = "Interface/ICONS/Achievement_Character_BloodElf_Female";
	namedIcons.dwarf = "Interface/ICONS/Achievement_Character_Dwarf_Male";
	namedIcons.gnome = "Interface/ICONS/Achievement_Character_Gnome_Female";
	namedIcons.human = "Interface/ICONS/Achievement_Character_Human_Male";
	namedIcons.nightelf = "Interface/ICONS/Achievement_Character_NightElf_Male";
	namedIcons["night elf"] = namedIcons.nightelf;
	namedIcons.orc = "Interface/ICONS/Achievement_Character_Orc_Male";
	namedIcons.tauren = "Interface/ICONS/Achievement_Character_Tauren_Female";
	namedIcons.troll = "Interface/ICONS/Achievement_Character_Troll_Male";
	namedIcons.undead = "Interface/ICONS/Achievement_Character_Undead_Male";
	namedIcons.ogre = "Interface/ICONS/Achievement_Reputation_Ogre";
	namedIcons.lostone = "Interface/ICONS/Achievement_Reputation_AshtongueDeathSworn";
	namedIcons["lost one"] = namedIcons.lostone;

	Media.texture(function(texture)
		local texture = textures[texture];
		if texture and type(texture) == "string" then
			return {
				name = texture,
				coords = coords
			};
		end;
	end);
end;

do
	local coords = ICON_COORDS;

	Media.spell(function(spell)
		if type(spell) ~= "string" and type(spell) ~= "number" then
			return;
		end;
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
		if type(item) ~= "string" and type(item) ~= "number" then
			return;
		end;
		item = select(10, GetItemInfo(item));
		if item then
			return {
				name = item,
				coords = coords
			};
		end;
	end);

	Media.SetAlias("item", "items", "icon", "icons", "loot", "drop", "treasure");

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

Media.texture(function(name)
	if type(name) ~= "string" then
		return;
	end;
	if name:find("[._-]") then
		return Media.texture[name:gsub("[._-]", " ")];
	end;
end);

Media.texture(function(name)
	if type(name) ~= "string" then
		return;
	end;
	if Strings.StartsWith(name:lower(), "interface[/\\]") then
		return name;
	end;
end);

Media.SetAlias("texture", "textures", "background", "backgrounds");

Frames=Frames or {};
function Frames.Texture(f, texture)
	f=Frames.AsRegion(f);
	texture = Media.texture[texture];
	local coords;
	if type(texture) == "table" then
		coords = texture.coords;
		texture = texture.name;
	end;
	if f:GetObjectType():find("Button$") then
		f:SetNormalTexture(texture);
		f=f:GetNormalTexture();
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
	else
		f:SetTexCoord(0, 1, 0, 1);
	end;
	return f;
end;

function Frames.PortraitTexture(f, target)
	f=Frames.AsRegion(f);
	if f:GetObjectType():find("Button$") then
		f=f:GetNormalTexture();
	elseif f:GetObjectType() ~= "Texture" then
		local t=f:CreateTexture();
		Anchors.ShareAll(t, f);
		f=t;
	end;
	SetPortraitTexture(f, target);
	return f;
end;

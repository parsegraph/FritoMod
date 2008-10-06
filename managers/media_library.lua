MediaLibrary = OOP.Class(ComponentSingleton);
local MediaLibrary = MediaLibrary;

MediaLibrary.DEFAULT = "default";

--[[
	MediaLibrary allows media of any form to be registered to a given name, so that it may be
	retrieved from a single, consistent source at a later time. If a name requested does not match
	to a given media, then a default will be returned. If no value can be found, an error is raised.
	
	The functions are dynamically generated when a type is registered. For example, calling:
	
	MediaLibrary:RegisterType("Font")
	
	will automatically create the following functions for convenience:
	
	MediaLibrary:AddFont("Times New Roman", "FRITZ__.TTF"); -- Registers this media with this name.
	
	MediaLibrary:GetFont("Times New Roman") -- Returns "FRITZ__.TTF"
	
	MediaLibrary:SetDefaultFont("ARIAL.TTF"); -- Sets Arial as the default.
	
	MediaLibrary:GetDefaultFont(); -- Returns "ARIAL.TTF"
	
-- Returns the media requested with the name, and returns nothing if no media is registered with that name.
	MediaLibrary:GetExplicitFont("Some Unregistered Font") 
	
--]]

function MediaLibrary:__Init()
    self.mediaTable = {};
    self.proxyLibraries = {};

	-- This implicitly sets the Default, since there's a name in here that has a key of 'Default'
	self:BulkAdd("Color", MATERIAL_TEXT_COLOR_TABLE);

	local function BreakColorTable(table)
		return {table.a or 1.0, table.r, table.g, table.b};
	end;

	local function ConvertToTable(alpha, ...)
        if select("#", ...) == 0 then
            return { ConvertColorToParts(alpha) };
        end;
        local red, green, blue = 0, 0, 0;
        if select("#", ...) == 2 then
            red = alpha;
            green, blue = ...;
            alpha = 1.0;
        else
            red, green, blue = ...;
        end;
        return { alpha, red, green, blue };
	end;

	----------------------------------------
	--  Colors
	----------------------------------------

	self:RegisterType("Color"); -- { A, R, G, B };

	self:Add("Color", "White", {1.0, 1.0, 1.0, 1.0});
	self:Add("Color", "Black", {1.0, 0.0, 0.0, 0.0});
	self:Add("Color", "Blue", {1.0, 0.0, 0.0, 1.0});
	self:Add("Color", "Yellow", {1.0, 1.0, 1.0, 0.0});

	-- Some Blizzard colors
	self:Add("Color", "Red", BreakColorTable(RED_FONT_COLOR));
	self:Add("Color", "Green", BreakColorTable(GREEN_FONT_COLOR));
	self:Add("Color", "Gray", BreakColorTable(GRAY_FONT_COLOR));

	self:Add("Color", "Warning", ConvertToTable(0xFFFF6347));
	self:Add("Color", "Error", ConvertToTable(0xFFB22222))
	self:Add("Color", "Debug", ConvertToTable(0xFFCD5C5C));
	self:Add("Color", "Message", ConvertToTable(0xFF6495ED));
    
	-- Class Colors
	for className, classColor in pairs(RAID_CLASS_COLORS) do 
		self:Add("Color", ProperNounize(className), BreakColorTable(classColor));
	end;

	----------------------------------------
	--  Fonts
	----------------------------------------

	self:RegisterType("Font");

	----------------------------------------
	--  Sounds
	----------------------------------------

    SOUNDS_DIR = "Interface\\Addons\\fritofski\\media\\sounds\\"

    SOUNDS = {
        "onoes",
        "eep",
        "hello",
        "silenced",
    }

	for i, sound_name in pairs(SOUNDS) do
        self:Add("Sound", sound_name, SOUNDS_DIR .. sound_name .. ".wav")
    end

	----------------------------------------
	--  Proxy Libraries
	----------------------------------------

    local sharedMedia = LibStub("LibSharedMedia-3.0");
    if sharedMedia then
        self:RegisterProxyLibrary(function(mediaType, mediaName, ...)
            return sharedMedia:Fetch(string.lower(mediaType), mediaName);
        end);
    end;

    self:RegisterType("Icon");
    self:RegisterProxyLibrary(
        function(mediaType, mediaName)
            if mediaType == "Icon" then
                return "Interface\\Icons\\" .. mediaName;
            end
        end
    )
end;

-------------------------------------------------------------------------------
--
--  MediaLibrary: Public Interface
--
-------------------------------------------------------------------------------

function MediaLibrary:Add(mediaType, mediaName, media)
	local mediaTable = self:RetrieveTable(mediaType);
	local existingMedia = mediaTable[mediaName];
	if existingMedia ~= nil then
		-- Some media has already been registered with this name...
		if existingMedia == media then
			-- But it's the same, so just return silently.
			return false;
		else
			-- Or it's different, then error.
			error("Non-identical media already registered with name '" .. mediaName .. "', type is '" .. mediaType .. "'");
		end;
	end;
	mediaTable[mediaName] = media;
	return true;
end;

function MediaLibrary:Get(mediaType, mediaName, errorOnMiss)
	local media = self:GetExplicit(mediaType, mediaName);
	if media ~= nil then
		return media;
	end;
	
	media = self:GetDefault(mediaType, mediaName);
	if media ~= nil then
		return media;
	end;
	
	if errorOnMiss then
		error(
			"No media found with name '" .. tostring(mediaName) .. "' of type '" .. tostring(mediaType) .. "'"
		);
	end;
end;

function MediaLibrary:RegisterType(mediaType)
	if self.mediaTable[mediaType] then
		-- The type is already registered, so simply return.
		return false;
	end;
	self.mediaTable[mediaType] = {};
	
	self["Add" .. mediaType] = function(self, mediaName, media)
		return self:Add(mediaType, mediaName, media);
	end;
	
	self["Get" .. mediaType] = function(self, mediaName)
		return self:Get(mediaType, mediaName);
	end;
	
	self["GetDefault" .. mediaType] = function(self)
		return self:GetDefault(mediaType);
	end;
	
	self["GetExplicit" .. mediaType] = function(self, mediaName)
		return self:GetExplicit(mediaType, mediaName);
	end;
	
	self["SetDefault" .. mediaType] = function(self, media)
		return self:Add(mediaType, MediaLibrary.DEFAULT, media);
	end;
	
	return true;
end;

function MediaLibrary:RegisterProxyLibrary(libraryFunc, ...)
    -- rawdebug("MediaLibrary - Registered Proxy Library!");
    libraryFunc = ObjFunc(libraryFunc, ...)
    table.insert(self.proxyLibraries, libraryFunc)
    return function()
        self.proxyLibraries = ListUtil:RemoveItem(self.proxyLibraries, libraryFunc);
    end;
end;

-------------------------------------------------------------------------------
--
--  MediaLibrary: Utility Interface
--
-------------------------------------------------------------------------------

function MediaLibrary:RetrieveTable(mediaType)
	if type(mediaType) ~= "string" then
		error("MediaLibrary: mediaType must be a string.");
	end;
	self:RegisterType(mediaType);
	return self.mediaTable[mediaType];
end;

function MediaLibrary:IterType(mediaType)
	return next, self:RetrieveTable(mediaType), nil;
end;

function MediaLibrary:GetExplicit(mediaType, mediaName)
	--rawdebug("MediaLibrary: Retrieving Explicit. (Type:", mediaType, ", Name:", mediaName, ")");
	local media = self:RetrieveTable(mediaType)[mediaName];
	if media == nil then
        for _, proxyLibraryGetter in ipairs(self.proxyLibraries) do
            media = proxyLibraryGetter(mediaType, mediaName);
            if media ~= nil then
                break
            end;
        end;
	end;
	return media;
end;

function MediaLibrary:GetDefault(mediaType)
	--debug("MediaLibrary: Retrieving Default. (Type:", mediaType, ")");
    return self:GetExplicit(mediaType, MediaLibrary.DEFAULT);
end;

function MediaLibrary:BulkAdd(mediaType, mediaTable)
	for mediaName, media in pairs(mediaTable) do
		self:Add(mediaType, mediaName, media);
	end;
end;

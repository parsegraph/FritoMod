-------------------------------------------------------------------------------
--
--    Utility Methods
--
-------------------------------------------------------------------------------

function DecorateTable(table, metatable)
    local oldMetatable = getmetatable(table);
    setmetatable(metatable, oldMetatable);
    setmetatable(table, metatable);
    return table, oldMetatable;
end;

function LazyInitialize(table, initializerFunc, ...)
    initializerFunc = ObjFunc(initializerFunc, ...);
    local oldMetatable;
    function initialize()
        setmetatable(table, oldMetatable);
        initializerFunc(table);
    end;
    table, oldMetatable = DecorateTable(table, {
        __index = function(self, key)
            initialize();
            return self[key];
        end,
        __call = function(self, ...)
            initialize();
            return self(...);
        end,
    });
    return table;
end;

function LazyMaskInitialize(realTable, initializerFunc, ...)
    local maskTable = setmetatable({}, {
        __index = realTable, 
        __call = function(self, ...) 
            return realTable(...) 
        end
    });
    LazyInitialize(maskTable, initializerFunc, ...);
    return maskTable;
end;

function LookupValue(table, value)
    for k,v in pairs(table) do
        if v == value then
            return true;
        end;
    end;
    return false;
end;

function CloneTable(table, destination)
    destination = destination or {};
    for k, v in pairs(table) do
        destination[k] = v;
    end;
    return destination;
end;

function CloneList(list, destination)
    destination = destination or {};
    for _, v in ipairs(list) do
        table.insert(destination, v);
    end;
    return destination;
end;

DIGITS = "0123456789"
ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
ALPHANUMERICS = DIGITS .. ALPHABET;

function IsCallable(value)
    local valueType = type(value);
    return valueType == "function" or (valueType == "table" and IsCallable(getmetatable(value).__call));
end;

function ProperNounize(name)
    name = tostring(name);
    return strupper(strsub(name, 1, 1)) .. strlower(strsub(name, 2));
end;

function ConvertToBase(base, number, digits)
    if not digits then
        digits = ALPHANUMERICS;
    end;
    if base > #digits or base < 2 then
        error("Invalid base: " .. base);
    end;
    local converted = "";
    while number > 0 do
        local place = (number % base) + 1;
        number = math.floor(number / base);
        converted = string.sub(digits, place, place) .. converted;
    end
    return converted;
end

function ConvertColorToParts(colorValue)
    local alpha, red, green, blue = 0, 0, 0, 0;
    alpha = bit.rshift(bit.band(colorValue, 0xFF000000), 24) / 255;
    red   = bit.rshift(bit.band(colorValue, 0x00FF0000), 16) / 255;
    green = bit.rshift(bit.band(colorValue, 0x0000FF00),  8) / 255;
    blue  = bit.rshift(bit.band(colorValue, 0x000000FF),  0) / 255;
    return alpha, red, green, blue;
end;

function tobool(msg)
	return not not msg;
end	

EMPTY_ARGS = {}

function ObjFunc(objOrFunc, funcOrName, ...)
    local numArgs = select("#", ...);
    if objOrFunc and funcOrName == nil and numArgs == 0 then
        --rawdebug("ObjFunc: Returning naked function directly.");
        return objOrFunc
    end;
    local args = EMPTY_ARGS
    if numArgs and numArgs > 0 then
        args = {};
        for i = 1, numArgs do 
            table.insert(args, select(i, ...));
        end;
    end;
    if type(objOrFunc) == "function" then
        --rawdebug("ObjFunc: Returning direct function partial.");
        if funcOrName ~= nil or #args > 0 then
            if args == EMPTY_ARGS then
                args = {};
            end;
            table.insert(args, 1, funcOrName);
        end;
        return function(...) 
            --rawdebug("ObjFunc: Calling direct function partial.");
            return objOrFunc(unpackall(args, {...}));
        end;
    elseif type(funcOrName) == "string" then
        --rawdebug("ObjFunc: Returning string-based method partial.");
        return function(...)
            --rawdebug("ObjFunc: Calling string-based method partial.");
            local func = objOrFunc[funcOrName];
            if not func or type(func) ~= "function" then
                error("Function not found with name: '" .. funcOrName .. "'");
            end;
            return func(objOrFunc, unpackall(args, {...}));
        end;
    elseif type(funcOrName) == "function" then
        --rawdebug("ObjFunc: Returning direct method partial.");
        if not objOrFunc then
            error("Object passed is falsy");
        end;
        return function(...)
            --rawdebug("ObjFunc: Calling direct method partial.");
            return funcOrName(objOrFunc, unpackall(args, {...}));
        end;
    else
        error(format("Invalid parameters given objOrFunc: '%s', funcOrName: '%s'", 
            objOrFunc or "<falsy>", 
            funcOrName or "<falsy>"
        ));
    end;
end;

function Unapplied(funcOrName, ...)
    local numArgs = select("#", ...);
    if numArgs == 1 then
        return objOrFunc
    end;
    local args = EMPTY_ARGS
    if numArgs and numArgs > 0 then
        args = {};
        for i = 1, select("#", ...) do
            table.insert(args, select(i, ...));
        end;
    end;
    return function(self)
        return ObjFunc(self, funcOrName, unpack(args));
    end;
end;

-------------------------------------------------------------------------------
--
--  Debugging Methods
--
-------------------------------------------------------------------------------

function dump_item(item)
	FritoModTooltip:SetOwner(FritoModFrame, "ANCHOR_NONE");
	FritoModTooltip:SetHyperlink(item);
	for i=1, FritoModTooltip:NumLines() do
	     local line = getglobal("FritoModTooltipTextLeft" .. i)
	     say(line:GetText());
	end
	FritoModTooltip:Hide();
end

function PrintTooltip(tooltip, includeRight) 
	if type(tooltip) == "string" then
		tooltip = getglobal(tooltip);
	end
	if not tooltip then 
		error("DumpTooltip given a falsy tooltip.");
	end
	local tooltipName = tooltip:GetName();
	for i = 1, tooltip:NumLines() do
		debug("Line " .. i .. ", left: '" .. getglobal(tooltipName .. "TextLeft" .. i):GetText() .. "'");
		if includeRight then 
			debug("Line " .. i .. ", right: '" .. getglobal(tooltipName .. "TextRight" .. i):GetText() .. "'");
		end;
	end
end;

-------------------------------------------------------------------------------
--
--    Bag Methods
--
-------------------------------------------------------------------------------

function IterateInventory(includeEmpty, receiverFunc)
	if type(includeEmpty) == "function" then
		receiverFunc = includeEmpty;
		includeEmpty = false;
	end;
	local itemLink;
	for bagID = 0, NUM_BAG_SLOTS do
		for slot = 1, GetContainerNumSlots(bagID) do
			itemLink = GetContainerItemLink(bagID, slot);
			if (itemLink or includeEmpty) then
				if receiverFunc(bagID, slot, itemLink, GetContainerItemInfo(bagID, slot)) == false then
					return
				end
			end
		end
	end
end

function GetSmallestStack(itemName)
	local candidateBagID, candidateSlot;
	local candidateCount = 99999 -- Arbitrary large number.
	IterateInventory(function(bagID, slot, itemLink, texture, itemCount, locked, quality, readable)
		if locked or not string.find(itemLink, itemName) or itemCount >= candidateCount then
			return
		end
		candidateBagID = bagID
		candidateSlot = slot
		candidateCount = itemCount
	end)
	return candidateBagID, candidateSlot
end

function GetItemByPriority(...)
	local itemName, bagID, slot;
	for i = 1, select("#", ...) do
		itemName = select(i, ...);
		bagID, slot = GetSmallestStack(itemName);
		if bagID ~= nil then
			return bagID, slot;
		end
	end
end;

-------------------------------------------------------------------------------
--
--    First Aid Methods
--
-------------------------------------------------------------------------------

local function testFirstAidSpellID(candidate)
	if type(candidate) == "number" then
		-- It's a spell ID, so we need to get the spellname.
		candidate = GetSpellName(candidate, BOOKTYPE_SPELL);
		if not spellName then
			-- It's an invalid ID, so return false.
			return false
		end
	end
	return string.find(candidate, "First Aid")
end;

FIRST_AID_SPELLID = nil;
function getFirstAidSpellID()
	if FIRST_AID_SPELLID ~= nil then
		-- We have a saved ID, so check that for accuracy.
		if testFirstAidSpellID(FIRST_AID_SPELLID) then
			-- It's correct, so return it.
			return FIRST_AID_SPELLID;
		end;
		-- Otherwise, fall through to get a correct spellID.
	end;
	FIRST_AID_SPELLID = nil;
	local spellIDCandidate = 1
	while true do
		local spellName = GetSpellName(spellIDCandidate, BOOKTYPE_SPELL);
		if not spellName then
			do break end;
		end;
		if testFirstAidSpellID(spellName) then
			FIRST_AID_SPELLID = spellIDCandidate;
			return spellIDCandidate
		end;
		spellIDCandidate = spellIDCandidate + 1;
	end
	debug("No valid First Aid SpellID found!")
end

-- Returns all elements from all table arguments
function unpackall( ... )
    local values = {}

    -- Collect values from all tables
    for i = 1, select( '#', ... ) do
        for _, value in ipairs( select( i, ... ) ) do
            values[#values + 1] = value
        end
    end

    return unpack( values )
end

-------------------------------------------------------------------------------
--
--  String Methods
--
-------------------------------------------------------------------------------

function concat(first, ...)
	local message = ""
	if first then
		message = tostring(first)
	end
	for i = 1, select("#", ...) do
		message = message .. " " .. tostring(select(i, ...))
	end
	return message
end;

function toitemstring(itemLink)
	local found, _, itemString = string.find(itemLink, "^|c%x+|H(.+)|h%[.+%]")
	return itemString
end

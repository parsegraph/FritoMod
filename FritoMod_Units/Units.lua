Units = {};
local Units = Units;

Units.factions = {
    HORDE = "horde",
    ALLIANCE = "alliance"
}

Units.ids = {
    PLAYER = "player",
    TARGET = "target",
    FOCUS = "focus",
    MOUSEOVER = "mouseover"
};

Units.classes = {
    DRUID = "druid",
    HUNTER = "hunter",
    MAGE = "mage",
    PALADIN = "paladin",
    PRIEST = "priest",
    ROGUE = "rogue",
    SHAMAN = "shaman",
    WARLOCK = "warlock",
    WARRIOR = "warrior",
};

Units.races = {
    GNOME = "gnome",
    DWARF = "dwarf",
    HUMAN = "human",
    NIGHTELF = "night_elf",
    DRAENEI = "draenei",

    ORC = "orc",
    TROLL = "troll",
    TAUREN = "tauren",
    UNDEAD = "scourge",
    BLOODELF = "blood_elf"
};

Units.realms = {
    LOCAL = "local"
};

Units.factions = {
    ALLIANCE = "alliance",
    HORDE = "horde",
    NEUTRAL = "neutral"
};

Units.genders = {
    MALE = "male",
    FEMALE = "female",
    UNKNOWN = "unknown"
};

Units.languages = {
    COMMON = "common",
    DARNASSIAN = "darnassian",
    DWARVEN = "dwarven",
    DRAENEI = "draenei",
    TAURAHE = "taurahe",
    ORCISH = "orcish",
    GUTTERSPEAK = "gutterspeak",
    DEMONIC = "demonic",
    DRACONIC = "draconic",
    KALIMAG = "kalimag",
    TITAN = "titan",
    GNOMISH = "gnomish",
    TROLL = "troll"
};

function Units.GetDefaultLanguage(unitID)
    if not self:GetExistence(unitID) then
        error("API.Units.GetDefaultLanguage - Unit does not exist: " .. unitID);
    end;
    local language = GetDefaultLanguage(unitID);
    return Units.languages[string.upper(language)];
end;

function Units.GetName(unitID)
    if not self:GetExistence(unitID) then
        error("API.Units.GetName - Unit does not exist: " .. unitID);
    end;
    local name = UnitName(unitID);
    return name;
end;

function Units.GetRealm(unitID)
    if not UnitIsVisible(unitID) then
        error("API.Units.GetRealm - Unit is not visible and cannot be accurately queried.");
    end;
    local _, realm = UnitName(unitID);
    if not realm then
        return Units.realm.LOCAL;
    end;
    return realm
end;

function Units.GetLevel(unitID)
    if not UnitExists(unitID) then
        error("API.Units.GetLevel - Unit does not exist: " .. unitID);
    end;
    local level = UnitLevel(unitID);
    if level == 0 then
        error("API.Units.GetLevel - Unit's level is 0: " .. unitID);
    end;
    return level;
end;

function Units.GetFaction(unitID)
    if not self:GetExistence(unitID) then
        error("API.Units.GetFaction - Unit does not exist: " .. unitID);
    end;
    local faction = string.upper(UnitFactionGroup(unitID));
    faction = Units.factions[faction];
    if not faction then
        return Units.factions.NEUTRAL;
    end;
    return factions;
end;

function Units.GetGender(unitID)
    if not self:GetExistence(unitID) then
        error("API.Units.GetGender - Unit does not exist: " .. unitID);
    end;
    local genderID = UnitSex(unitID);
    if genderID == 2 then
        return Units.genders.MALE
    end;
    if genderID == 3 then
        return Units.genders.FEMALE;
    end;
    return Units.genders.UNKNOWN;
end;

function Units.GetExistence(unitID)
    return Bool(UnitExists(unitID));
end;

function Units.GetGUID(unitID)
    if not self:GetExistence(unitID) then
        error("API.Units.GetGUID - Unit does not exist: " .. unitID);
    end;
    local guid = UnitGUID(unitID);
    return guid;
end;

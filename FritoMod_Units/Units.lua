API.Unit = {};
local Unit = API.Unit;

Unit.factions = {
    HORDE = "horde",
    ALLIANCE = "alliance"
}

Unit.ids = {
    PLAYER = "player",
    TARGET = "target",
    FOCUS = "focus",
    MOUSEOVER = "mouseover"
};

Unit.classes = {
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

Unit.races = {
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

Unit.realms = {
    LOCAL = "local"
};

Unit.factions = {
    ALLIANCE = "alliance",
    HORDE = "horde",
    NEUTRAL = "neutral"
};

Unit.genders = {
    MALE = "male",
    FEMALE = "female",
    UNKNOWN = "unknown"
};

Unit.languages = {
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

function Unit:GetDefaultLanguage(unitID)
    if not self:GetExistence(unitID) then
        error("API.Unit:GetDefaultLanguage - Unit does not exist: " .. unitID);
    end;
    local language = GetDefaultLanguage(unitID);
    return Unit.languages[string.upper(language)];
end;

function Unit:GetName(unitID)
    if not self:GetExistence(unitID) then
        error("API.Unit:GetName - Unit does not exist: " .. unitID);
    end;
    local name = UnitName(unitID);
    return name;
end;

function Unit:GetRealm(unitID)
    if not UnitIsVisible(unitID) then
        error("API.Unit:GetRealm - Unit is not visible and cannot be accurately queried.");
    end;
    local _, realm = UnitName(unitID);
    if not realm then
        return Unit.realm.LOCAL;
    end;
    return realm
end;

function Unit:GetLevel(unitID)
    if not UnitExists(unitID) then
        error("API.Unit:GetLevel - Unit does not exist: " .. unitID);
    end;
    local level = UnitLevel(unitID);
    if level == 0 then
        error("API.Unit:GetLevel - Unit's level is 0: " .. unitID);
    end;
    return level;
end;

function Unit:GetFaction(unitID)
    if not self:GetExistence(unitID) then
        error("API.Unit:GetFaction - Unit does not exist: " .. unitID);
    end;
    local faction = string.upper(UnitFactionGroup(unitID));
    faction = Unit.factions[faction];
    if not faction then
        return Unit.factions.NEUTRAL;
    end;
    return factions;
end;

function Unit:GetGender(unitID)
    if not self:GetExistence(unitID) then
        error("API.Unit:GetGender - Unit does not exist: " .. unitID);
    end;
    local genderID = UnitSex(unitID);
    if genderID == 2 then
        return Unit.genders.MALE
    end;
    if genderID == 3 then
        return Unit.genders.FEMALE;
    end;
    return Unit.genders.UNKNOWN;
end;

function Unit:GetExistence(unitID)
    return Bool(UnitExists(unitID));
end;

function Unit:GetGUID(unitID)
    if not self:GetExistence(unitID) then
        error("API.Unit:GetGUID - Unit does not exist: " .. unitID);
    end;
    local guid = UnitGUID(unitID);
    return guid;
end;

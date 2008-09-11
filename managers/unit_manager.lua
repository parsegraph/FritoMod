UnitManager = {
    registry = {}
};
local UnitManager = UnitManager;

function UnitManager:FetchByID(unitID, fetch_only)
    return self:Fetch(API.Unit:GetGUID(unitID), fetch_only);
end;

function UnitManager:Fetch(unitID, fetch_only)
    local guid = API.Unit:GetGUID(unitID);
    local unit = self.registry[guid]
    if unit then 
        return unit;
    end;
    if not fetch_only then
        return self:Register(name, realm);
    end;
end;

function UnitManager:Register(name, realm, unit)
    local realmRegistry = self:GetRealmRegistry(realm);
    local incumbentUnit = realmRegistry[name];
    if incumbentUnit and incumbentUnit ~= unit then
        error("UnitManager:Register - Unit registration clash!");
    end;
    if not unit then
        unit = Unit:new();
    end;
    realmRegistry[name] = unit;
    return unit;
end;

function UnitManager:GetRealmRegistry(realm)
    if not realm then
        realm = Unit:GetPlayerRealm();
    end;
    local realmRegistry = registry[realm];
    if not realmRegistry then
        realmRegistry = {};
        registry[realm] = realmRegistry;
    end;
    return realmRegistry;
end;

function UnitManager:PopulateBaseFrom(unitID)
    local name, realm = Unit:GetFullName(unitID);

end;

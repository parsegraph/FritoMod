UnitManager = {
    registry = {}
};
local UnitManager = UnitManager;

function UnitManager:FetchByID(unitID, fetch_only)
    return self:Fetch(UnitGUID(unitID), fetch_only);
end;

function UnitManager:Fetch(unitID)
    local guid = UnitGUID(unitID);
    return self.registry[guid]
end;

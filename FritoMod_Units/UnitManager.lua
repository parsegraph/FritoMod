UnitManager = {
    registry = {}
};
local UnitManager = UnitManager;

function UnitManager:FetchByID(unitID, fetch_only)
    return self:Fetch(API.Unit:GetGUID(unitID), fetch_only);
end;

function UnitManager:Fetch(unitID)
    local guid = API.Unit:GetGUID(unitID);
    return self.registry[guid]
end;

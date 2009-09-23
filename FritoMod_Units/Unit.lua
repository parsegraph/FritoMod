Unit = OOP.Class(EventDispatcher)
local Unit = Unit;

Data:MixinScalar(Unit, "Name");
Data:MixinScalar(Unit, "Faction");
Data:MixinScalar(Unit, "Realm");
Data:MixinScalar(Unit, "Class");
Data:MixinScalar(Unit, "Race");
Data:MixinScalar(Unit, "Gender");
Data:MixinRange(Unit, "Health");

function Unit:LoadBase(name, realm, faction, class, race, gender)
    self:SetName(name);
    self:SetRealm(realm);
    self:SetFaction(faction);
    self:SetClass(class);
    self:SetRace(race);
    self:SetGender(gender);
end;

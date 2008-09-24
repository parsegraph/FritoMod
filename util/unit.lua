Unit = OOP.Class(EventDispatcher)
local Unit = Unit;

Data:MixinScalar("Name");
Data:MixinScalar("Faction");
Data:MixinScalar("Realm");
Data:MixinScalar("Class");
Data:MixinScalar("Race");
Data:MixinScalar("Gender");
Data:MixinRange("Health");

function Unit:LoadBase(name, realm, faction, class, race, gender)
    self:SetName(name);
    self:SetRealm(realm);
    self:SetFaction(faction);
    self:SetClass(class);
    self:SetRace(race);
    self:SetGender(gender);
end;

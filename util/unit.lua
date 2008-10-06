Unit = OOP.Class(EventDispatcher)
local Unit = Unit;

Unit.__AddInitializer(function(class)
    Data:MixinScalar(class, "Name");
    Data:MixinScalar(class, "Faction");
    Data:MixinScalar(class, "Realm");
    Data:MixinScalar(class, "Class");
    Data:MixinScalar(class, "Race");
    Data:MixinScalar(class, "Gender");
    Data:MixinRange(class, "Health");
end);

function Unit:LoadBase(name, realm, faction, class, race, gender)
    self:SetName(name);
    self:SetRealm(realm);
    self:SetFaction(faction);
    self:SetClass(class);
    self:SetRace(race);
    self:SetGender(gender);
end;

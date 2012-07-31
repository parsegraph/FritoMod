if nil ~= require then
    require "wow/api/Frame";
    require "fritomod/Frames";
    require "labs/UI-ActionPlate"
end;
local Suite=CreateTestSuite("labs.UI-SpellCounter");

function Suite:TestCreation()
    local parent = CreateFrame("Frame");

    local counter = UI.SpellCounter:New(parent, {});
end;

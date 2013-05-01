if nil ~= require then
    require "fritomod/Media-Color";
    require "fritomod/Frames";
    require "fritomod/Anchors";
end;

local Suite=CreateTestSuite("fritomod.UI-Layered");

function Suite:TestRemovals()
    local lay = UI.Layered:New(UIParent);
    lay:AddColor("background", "black");
    lay:AddColor("middle", "green", .2);
    lay:AddColor("top", "border");
    lay:Order("background", "middle", "top", "highlight");
    Assert.Equals(
        {"background", "middle", "top", "highlight"},
        lay:GetOrder());
    lay:Remove("top");
    Assert.Equals(
        {"background", "middle", "top", "highlight"},
        lay:GetOrder(),
        "Ordering is not affected by removals");
    lay:RemoveOrder("top");
    Assert.Equals(
        {"background", "middle", "highlight"},
        lay:GetOrder(),
        "RemoveOrder removes top element");
    lay:Destroy();
end;

function Suite:TestEverthing()
    local lay = UI.Layered:New(UIParent);

    Frames.WH(lay, 100);
    Anchors.Center(lay);

    for i=1, 63 do
       local t = Frames.Color(lay, i / 32, 1, 1, .2);
       Anchors.Clear(t);
       Frames.WH(t, 8 * (64 - i));
       Anchors.Center(t);
       lay:Add(i, t);
    end;
end;

if nil ~= require then
    require "fritomod/Mapper";
    require "fritomod/Frames";
    require "fritomod/Media-Color";
end;

local Suite = CreateTestSuite("fritomod.UI-List");

-- Just a simple proof-of-concept, really.
function Suite:TestList()
    local values = {
        "red",
        "yellow",
        "blue"
    };
    local mapper = Mapper:New();
    mapper:UseValueMapper(function(color)
        local frame = Frames.New();
        Frames.WH(frame, 40);
        Frames.Color(frame, color);
        return frame;
    end);
    mapper:AddSource(values);

    local frames = {};
    mapper:AddDest(frames);

    local view = UI.List:New();
    mapper:OnUpdate(view, "Update");
    local myRef;
    view:OnUpdate(function(ref)
        myRef = ref;
    end);
    local flag = Tests.Flag();
    view:OnUpdate(flag.Raise);
    view:SetContent(frames);
    view:SetLayout(Anchors.HJustify, "topleft");

    flag.Assert();
    Assert.Equals(frames[1], myRef, "reference was set");
    view:Reset();

    local counter = Tests.Counter();
    Iterators.EachValue(view:Iterator(), counter.Hit);
    counter.Assert(3);
end;

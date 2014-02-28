if nil ~= require then
    require "fritomod/Mapper";
    require "fritomod/Frames";
    require "fritomod/Media-Color";
end;

local Suite = CreateTestSuite("fritomod.UI-List");

-- Just a simple proof-of-concept, really.
function Suite:TestList()
    local mapper = Mapper:New();
    mapper:SetMapper(function(color, frame)
        if not color then
            frame:Destroy();
            return;
        end;
        if not frame then
            frame = Frames.New();
            Frames.WH(frame, 40);
        end;
        Frames.Color(frame, color);
        return frame;
    end);
    mapper:SetSource({
        "red",
        "yellow",
        "blue"
    });

    local frames = mapper:Get();

    local view = UI.List:New();
    view:SetContent(mapper:Get());

    local myRef;
    view:OnUpdate(function(ref)
        myRef = ref;
    end);
    local flag = Tests.Flag();
    view:OnUpdate(flag.Raise);
    view:SetLayout(Anchors.HJustify, "topleft");

    flag.Assert();
    Assert.Equals(frames[1], myRef, "reference was set");
    view:Reset();

    local counter = Tests.Counter();
    Iterators.EachValue(view:Iterator(), counter.Hit);
    counter.Assert(3);
end;

-- vim: set et :

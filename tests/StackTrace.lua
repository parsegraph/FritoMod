local Suite=UnitTest("StackTrace");

function Suite:TestFilter()
    local stack=StackTrace:New();
    local f=Tests.Flag();
    local r=Tests.AddStackFilter(function(level)
        f.Raise();
        return false;
    end);
    Assert.Equals(0, #stack:Filtered():GetStack());
    f.Assert();
    r();
    Assert.Equals(#stack:GetStack(), #stack:Filtered():GetStack());
end;

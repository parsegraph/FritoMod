if nil ~= require then
    require "wow/EditBox";
end;
local Suite = CreateTestSuite("fritomod.Callbacks-Text");

function Suite:TestEscapePressed()
    local f = Frames.New("EditBox");
    local flag = Tests.Flag();
    local a = Callbacks.OnEscape(f, flag.Raise);
    a();
    local b = Callbacks.OnEscape(f, flag.Raise);
    b();
end;

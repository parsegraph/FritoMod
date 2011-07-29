if nil ~= require then
    require "fritomod/Lists";
    require "fritomod/Strings";
end;

local Suite=IntegrationTest("fritomod.Iteration");

function Suite:TestContainsString()
    local buttons={"LeftButton", "RightButton"};
    for i=1, #buttons do
        assert(Lists.Contains(buttons, buttons[i], Strings.StartsWith), buttons[i]);
    end;
end;

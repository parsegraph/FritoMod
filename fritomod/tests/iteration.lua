if nil ~= require then
    require "Lists";
    require "Strings";
end;

local Suite=IntegrationTest("Iteration");

function Suite:TestContainsString()
    local buttons={"LeftButton", "RightButton"};
    for i=1, #buttons do
        assert(Lists.Contains(buttons, buttons[i], Strings.StartsWith), buttons[i]);
    end;
end;

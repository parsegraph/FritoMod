ReflectiveTestSuite = OOP.Class(TestSuite);
local ReflectiveTestSuite = ReflectiveTestSuite;

function ReflectiveTestSuite:Constructor(name)
    self.class.super.Constructor(self, name);

    local tests = OrderedMap();

    function self:__index(key)
        local value = self.class[key];
        if value then
            return value;
        end;
        return tests[key];
    end;

    function self:GetTests()
        return tests:Iterator();
    end;

    function self:__newindex(key, value)
        tests[key] = value;
    end;

end;

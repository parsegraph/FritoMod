ReflectiveTestSuite = OOP.Class(TestSuite);
local ReflectiveTestSuite = ReflectiveTestSuite;

function ReflectiveTestSuite:Constructor(name)
    self.class.super.Constructor(self, name);

    local tests = Metatables.OrderedMap();

    function self:GetTests()
        local name = self:GetName();
        local iterable = tests:Iterator();
        return Iterators.DecorateIterator(Iterators.FilteredIterator(iterable, 
            function(key, value)
                return type(key) == "string" and key:sub(1, 4) == "Test";
            end), function(key, value)
                if name then
                    return format("%s.%s", name, key), value;
                end;
                return key, value;
            end
        );
    end;

    function self:__index(key)
        local value = self.class[key];
        if value then
            return value;
        end;
        return tests[key];
    end;

    function self:__newindex(key, value)
        tests[key] = value;
    end;

end;

if nil ~= require then
    require "FritoMod_OOP/OOP-Class";

    require "FritoMod_Collections/Metatables";

    require "FritoMod_Testing/TestSuite";
end;

ReflectiveTestSuite = OOP.Class(TestSuite);
local ReflectiveTestSuite = ReflectiveTestSuite;

function ReflectiveTestSuite:Constructor(name)
    self.class.super.Constructor(self, name);

    local tests = Metatables.OrderedMap();

    function self:GetTests()
        local name = self:GetName();
        local iterator = tests:Iterator();
        iterator = Iterators.FilteredIterator(iterator, function(key, value)
           return type(key) == "string" and key:sub(1, 4) == "Test";
        end);
        iterator = Iterators.DecorateIterator(iterator, function(key, value)
            value = ForcedMethod(self, value);
            if name then
                return ("%s.%s"):format(name, key), value;
            end;
            return key, value;
        end);
        return iterator;
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

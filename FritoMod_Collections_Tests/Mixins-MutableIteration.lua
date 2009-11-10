if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_Collections/Mixins";
end;

if Mixins == nil then
    Mixins = {};
end;

-- Mixes in test cases for the functions added by Mixins.MutableIteration. This also mixes in
-- test cases for functions added by Mixins.Iteration. As a consequence, the functions required
-- by that mixin are also required by this one.
--
-- Suite
--     the test suite that is the target of this mixin
-- library
--     the table that contains the Mixin.Iteration-added functions tested by the specified Suite
-- returns
--     Suite
function Mixins.MutableIterationTests(Suite, library)
    Mixins.IterationTests(Suite, library);

    function Suite:TestDelete()
        local keys = Suite:GetKeys();
        local iterable = Suite:NewIterable();
        local key = keys[1];
        local value = library.Delete(iterable, key);
        Assert.Equals(library.Get(Suite:NewIterable(), key), value, "Removed value is returned");
        Assert.Equals(2, library.Size(iterable), "Iterable's size decreases after removal");
        local newValue = library.Get(iterable, key);
        if type(key) ~= "number" then
            Assert.Equals(nil, newValue, "Removed value is removed from map-like iterable");
        else
            Assert.Equals(library.Get(Suite:NewIterable(), key + 1), newValue, "Value is removed and elements are shifted");
        end;
    end;

    function Suite:TestClear()
        local iterable = Suite:NewIterable();
        library.Clear(iterable);
        assert(library.IsEmpty(iterable), "Iterable is empty");
        assert(library.Equals(iterable, Suite:EmptyIterable()), "Iterable is equal to an empty iterable");
    end;

    function Suite:TestInsertPair()
        if not rawget(library, "InsertPair") then
            return true;
        end;
        local iterable = Suite:EmptyIterable();
        local remover = library.InsertPair(iterable, "Foo", "Bar");
        assert(library.ContainsValue(iterable, "Bar"), "InsertPair inserts the specified value");
        remover();
        assert(not library.ContainsValue(iterable, "Bar"), "InsertPair returns remover that undoes insertion");
    end;

    return Suite;
end;

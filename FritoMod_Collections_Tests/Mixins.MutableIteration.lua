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
        local value = library.Delete(iterable, keys[1]);
        Assert.Equals(library.Get(Suite:NewIterable(), keys[1]), value, "Removed value is returned");
        assert(library.Get(iterable, keys[1]) == nil, "Removed value is actually removed");
    end;

    function Suite:TestClear()
        local iterable = Suite:NewIterable();
        library.Clear(iterable);
        assert(library.IsEmpty(iterable), "Iterable is empty");
        assert(library.Equals(iterable, Suite:EmptyIterable()), "Iterable is equal to an empty iterable");
    end;

    return Suite;
end;

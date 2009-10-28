if Mixins == nil then
    Mixins = {};
end;

function Mixins.MutableIterationTests(Suite, library)
    Mixins.IterationTests(Suite, library);

    function Suite:TestDelete()
        local keys = Suite:GetKeys();
        local iterable = Suite:NewIterable();
        local value = Suite:Delete(iterable, keys[1]);
        Assert.Equals(library.Get(Suite:NewIterable(), keys[1]), value, "Removed value is returned");
        assert(library.Get(iterable, keys[1]) == nil, "Removed value is actually removed");
    end;

    function Suite:TestClear()
        local iterable = Suite:NewIterable();
        library.Clear(iterable);
        assert(library.IsEmpty(iterable), "Iterable is empty");
        assert(library.Equals(iterable, Suite:EmptyIterable()), "Iterable is equal to an empty iterable");
    end;

end;

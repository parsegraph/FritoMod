if Mixins == nil then
    Mixins = {};
end;

function Mixins.IterationTests(Suite, library)
    if Suite.NewIterable == nil then
        function Suite:NewIterable()
            local iterable = library.New();
            library.Insert(iterable, "A");
            library.Insert(iterable, "BB");
            library.Insert(iterable, "CCC");
            return iterable;
        end;
    end;

    function Check(iterable, key, value)
        Assert.Equals(library.Get(iterable, key), value, "Key is in iterable: " .. tostring(key));
        Assert.Equals(library.KeyFor(iterable, value), key, "Value is in iterable: " .. tostring(key));
    end;

    function Suite:TestBidiIterator()
        local iterable = self:NewIterable();
        local counter = Tests.Counter();
        for key, value in library.BidiPairIterator(iterable) do
            counter.Hit();
            Check(iterable, key, value);
        end;
        counter.Assert(3);
    end;

    function Suite:TestBidiIteratorNext()
        local iterable = self:NewIterable();
        local iterator = library.BidiPairIterator(iterable);
        local counter = Tests.Counter();
        while true do
            local key, value = iterator:Next();
            if key == nil then
                break;
            end;
            counter.Hit();
            Check(iterable, key, value);
        end;
        counter.Assert(3);
    end;

    function Suite:TestBidiIteratorPrevious()
        local iterable = self:NewIterable();
        local counter = Tests.Counter();
        local iterator = library.BidiPairIterator(iterable);
        -- Seek the iterator to the end
        while iterator() do end;
        while true do
            local key, value = iterator:Previous();
            if key == nil then
                break;
            end;
            counter.Hit();
            Check(iterable, key, value);
        end;
        counter.Assert(3);
    end;

    function Suite:TestBidiIteratorStress()
        local iterable = Suite:NewIterable();
        local iterator = library.BidiPairIterator(iterable);
        local stride = 0;
        while stride < library.Size(iterable) do
            stride = stride + 1;
            for i=1, stride do
                Check(iterable, iterator:Next());
            end;
            for i=stride, 2, -1 do
                Check(iterable, iterator:Previous());
            end;
            -- One extra for the nil value.
            iterator:Previous();
        end;
    end;
end;

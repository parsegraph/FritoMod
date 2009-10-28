if Mixins == nil then
    Mixins = {};
end;

function Mixins.IterationTests(Suite, library)

    local function Check(iterable, key, value)
        assert(library.ContainsValue(iterable, value), "Iterable contains value: " .. tostring(value));
        assert(library.ContainsKey(iterable, key), "Iterable contains key: " .. tostring(key));
        assert(library.ContainsPair(iterable, key, value), 
            format("Iterable contains pair (%s, %s)", tostring(key), tostring(value)));
        if rawget(library, "Get") then
            Assert.Equals(value,library.Get(iterable, key), "Key is in iterable: " .. tostring(key));
        end;
        if rawget(library, "KeyFor") then
            Assert.Equals(key, library.KeyFor(iterable, value), "Value is in iterable: " .. tostring(key));
        end;
    end;
    
    local choke = Tests.Choke(100);

    function Suite:TestKeyIterator()
        local iterable = Suite:NewIterable();
        local keys = {};
        for key in library.KeyIterator(iterable) do
            choke();
            library.ContainsKey(iterable, key);
            keys[key] = true;
        end;
        local controlKeys = Suite:GetKeys();
        for i=1, #controlKeys do
            local controlKey = controlKeys[i];
            assert(keys[controlKey], "Iterated over key: " .. tostring(controlKey));
        end;
    end;

    function Suite:TestValueIterator()
        local iterable = Suite:NewIterable();
        local values = {};
        for value in library.ValueIterator(iterable) do
            choke();
            library.ContainsValue(iterable, value);
            values[value] = true;
        end;
        local controlValues = Suite:GetValues();
        for i=1, #controlValues do
            choke();
            local controlValue = controlValues[i];
            assert(keys[controlValue], "Iterated over value: " .. tostring(controlValue));
        end;
    end;

    function Suite:TestBidiIterator()
        local iterable = Suite:NewIterable();
        local counter = Tests.Counter();
        for key, value in library.BidiPairIterator(iterable) do
            counter.Hit();
            Check(iterable, key, value);
        end;
        counter.Assert(3);
    end;

    function Suite:TestBidiIteratorNext()
        local iterable = Suite:NewIterable();
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
        local iterable = Suite:NewIterable();
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

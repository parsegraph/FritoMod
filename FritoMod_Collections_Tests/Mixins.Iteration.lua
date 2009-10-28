if Mixins == nil then
    Mixins = {};
end;

-- Mixes in many test cases for the functions added by Mixins.Iteration. 
--
-- The specified Suite must provide the following methods:
--
-- * FalsyIterable requires a one-element iterable with false for its key
-- and false for its value
-- * NewIterable requires a three-element iterable, with keys and values 
-- that are all unique. (No key can also be a value, and vice versa)
-- * EmptyIterable requires a zero-element iterable
--
-- Each of these functions must creates a new iterable, but that iterable 
-- must contain the same elements as any other iterable returned by that
-- function.
--
-- Suite
--     the test suite that is the target of this mixin
-- library
--     the table that contains the Mixin.Iteration-added functions tested by 
--     the specified Suite
-- returns
--     Suite
function Mixins.IterationTests(Suite, library)

    function Suite:CheckKey(key, assertion)
        assert(library.ContainsKey(Suite:NewIterable(), key), "Iterable contains key: " .. tostring(key));
    end;
    
    function Suite:CheckValue(value, assertion)
        assert(library.ContainsValue(Suite:NewIterable(), value), "Iterable contains value: " .. tostring(value));
    end;

    function Suite:CheckPair(key, value, assertion)
        assert(library.ContainsPair(Suite:NewIterable(), key, value), 
            format("Iterable contains pair (%s, %s)", tostring(key), tostring(value)));
    end;

    function Suite:TestFalsyIterable()
        assert(type(Suite.FalsyIterable) == "function", "Suite has a FalsyIterable function");
        local iterable = Suite:FalsyIterable();
        assert(iterable ~= nil, "Iterable is not nil");
        assert(iterable ~= Suite:FalsyIterable(), "FalsyIterable returns a unique value");
        for key, value in library.Iterator(Suite:FalsyIterable()) do
            assert(key == false or key == 1 or key == nil, 
                "Key is falsy or one for false-key iterable. Key: " .. tostring(key));
            assert(value == false or value == nil, 
                "Value is falsy for false-key iterable");
            Assert.Equals(false, value, "Key is false for false-key iterable.");
        end;
    end;

    function Suite:TestNewIterable()
        assert(type(Suite.NewIterable) == "function", "Suite has a NewIterable function");
        local iterable = Suite:NewIterable();
        assert(iterable ~= nil, "Iterable is not nil");
        assert(iterable ~= Suite:NewIterable(), "NewIterable returns a unique value");
        local counter = Tests.Counter();
        local values = {};
        for key, value in library.Iterator(Suite:NewIterable()) do
            counter.Hit();
            assert(values[key] == nil, "Key is unique for returned iterable. Key: " .. tostring(key));
            values[key] = true;
            assert(values[value] == nil, "Value is unique for returned iterable. Value: " .. tostring(value));
            values[value] = true;
        end;
        counter.Assert(3, "NewIterable returns a 3-element iterable");
    end;

    function Suite:TestEmptyIterable()
        assert(type(Suite.EmptyIterable) == "function", "Suite has a Emptyfunction");
        local iterable = Suite:EmptyIterable();
        assert(iterable ~= nil, "Iterable is not nil");
        assert(iterable ~= Suite:EmptyIterable(), "EmptyIterable returns a unique value");
        for key, value in library.Iterator(Suite:EmptyIterable()) do
            error("Empty iterable contains elements. Key: " .. tostring(key) .. ", Value: " .. tostring(value));
        end;
    end;

    function Suite:TestSize()
        Assert.Equals(3, library.Size(Suite:NewIterable()), "Size reports three for three-element iterable");
        Assert.Equals(1, library.Size(Suite:FalsyIterable()), "Size reports one for iterable with one falsy pair");
        Assert.Equals(0, library.Size(Suite:EmptyIterable()), "Size reports zero for empty iterable");
    end;

    function Suite:TestIsEmpty()
        assert(not library.IsEmpty(Suite:NewIterable()), "IsEmpty returns false for non-empty iterable");
        assert(not library.IsEmpty(Suite:FalsyIterable()), "IsEmpty returns false for an iterable with falsy pairs"); 
        assert(not library.IsEmpty(Suite:EmptyIterable()), "IsEmpty returns true for empty iterable");
    end;

    function Suite:TestContainsKey()
        local iterable = Suite:NewIterable();
        local key = Suite:GetKeys()[1];
        assert(library.ContainsKey(iterable, key), "ContainsKey is true for contained key: " .. key);
        assert(not library.ContainsKey(iterable, "This key is not in iterable"), "ContainsKey returns false for missing key");
    end;

    function Suite:TestKeyIterator()
        local choke = Tests.Choke(100);
        local iterable = Suite:NewIterable();
        local keys = {};
        for key in library.KeyIterator(iterable) do
            choke();
            Suite:CheckKey(key, "KeyIterator iterates over contained key: " .. tostring(key));
            keys[key] = true;
        end;
        local controlKeys = Suite:GetKeys();
        for i=1, #controlKeys do
            choke();
            local controlKey = controlKeys[i];
            assert(keys[controlKey], "KeyIterator iterated over key: " .. tostring(controlKey));
        end;
    end;

    function Suite:TestValueIterator()
        local choke = Tests.Choke(100);
        local iterable = Suite:NewIterable();
        local values = {};
        for value in library.ValueIterator(iterable) do
            choke();
            Suite:CheckValue(value, "ValueIterator iterates over contained key: " .. tostring(value));
            values[value] = true;
        end;
        local controlValues = Suite:GetValues();
        for i=1, #controlValues do
            choke();
            local controlValue = controlValues[i];
            assert(values[controlValue], "ValueIterator iterated over value: " .. tostring(controlValue));
        end;
    end;

    function Suite:TestBidiIterator()
        local iterable = Suite:NewIterable();
        local counter = Tests.Counter();
        for key, value in library.BidiPairIterator(iterable) do
            counter.Hit();
            Suite:CheckPair(key, value);
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
            Suite:CheckPair(key, value);
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
            Suite:CheckPair(key, value);
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
                Suite:CheckPair(iterator:Next());
            end;
            for i=stride, 2, -1 do
                Suite:CheckPair(iterator:Previous());
            end;
            -- One extra for the nil value.
            iterator:Previous();
        end;
    end;

    return Suite;
end;

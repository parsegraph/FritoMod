if nil ~= require then
    require "tests/Mixins-ArrayTests";
    require "tests/Mixins-TableTests";
end;

local Suite=CreateTestSuite("Iterators");

local arraySuite = ReflectiveTestSuite:New("Iterators (arrays)");
Mixins.ArrayTests(arraySuite, Iterators);
function arraySuite:Array(...)
    return Iterators.IterateList({...});
end;

function arraySuite:TestRandom()
	return nil;
end;

local tableSuite = ReflectiveTestSuite:New("Iterators (tables)");
Mixins.TableTests(tableSuite, Iterators);
function tableSuite:Table(t)
	if t == nil then
		return function()
			-- We don't use Noop since that wouldn't be a unique value
		end;
	end;
    return Iterators.IterateMap(t);
end;

function Suite:TestVisibleFields()
    local foo = {
        a = 1,
        b = 2,
        c = 3
    };
    local copy = {};
    for key, value in Iterators.IterateVisibleFields(foo) do
        copy[key] = value;
    end;
    Assert.Equals(foo, copy, "Simple visible fields");
end;

function Suite:TestVisibleFieldsWhenNested()
    local foo = {
        a = 1,
        b = 2,
        c = 3
    };
    setmetatable(foo, {
        __index = {
            d = 4
        }
    });
    local copy = {};
    for key, value in Iterators.IterateVisibleFields(foo) do
        copy[key] = value;
    end;
    foo.d = 4;
    Assert.Equals(foo, copy, "Field is iterated when contained in a metatable");
end;

function Suite:TestVisibleFieldsWhenOverridden()
    local foo = {
        a = 1,
        b = 2,
        c = 3
    };
    setmetatable(foo, {
        __index = {
            c = 4,
        }
    });
    local flag = Tests.Flag();
    for key, value in Iterators.IterateVisibleFields(foo) do
        if key == "c" then
            assert(not flag:IsSet(), "C was already iterated");
            flag:Raise();
            assert(value == 3, "Iterated over an invalid c value. Value was: " .. tostring(value));
        end;
    end;
    assert(flag:IsSet(), "C was never iterated");
end;

function Suite:TestVisibleFieldsCombinedWithFilteredIterator()
    local obj = {
        a = true,
        bb = true,
        c = true,
        dd = true,
        e = false
    };
    local iterator = Iterators.IterateVisibleFields(obj);
    iterator = Iterators.FilteredIterator(iterator, function(key, value)
        return #key % 2 == 0;
    end);
    local counter = Tests.Counter();
    Iterators.Each(iterator, counter.Hit);
    counter.Assert(2);
end;

function Suite:TestCounter()
    Assert.Equals({1,2,3}, Iterators.Consume(Iterators.Counter(1,3)));
    Assert.Equals({3,2,1}, Iterators.Consume(Iterators.Counter(3,1)));
    Assert.Equals({1,2,3}, Iterators.Consume(Iterators.Counter(3)));
    Assert.Equals({1,3,5}, Iterators.Consume(Iterators.Counter(1,5,2)));
    local unbounded=Iterators.Counter();
    Assert.Equals(1, unbounded());
    Assert.Equals(2, unbounded());
    Assert.Equals(3, unbounded());
end;

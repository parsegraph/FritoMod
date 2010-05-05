if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_Collections/Iterators";

    require "FritoMod_Collections_Tests/Mixins-ArrayTests";
    require "FritoMod_Collections_Tests/Mixins-TableTests";
end;

local arraySuite = ReflectiveTestSuite:New("FritoMod_Collections.Iterators (arrays)");
Mixins.ArrayTests(arraySuite, Iterators);
function arraySuite:Array(...)
    return Iterators.IterateList({...});
end;

local tableSuite = ReflectiveTestSuite:New("FritoMod_Collections.Iterators (tables)");
Mixins.TableTests(tableSuite, Iterators);
function tableSuite:Table(t)
	if t == nil then
		return function()
			-- We don't use Noop since that wouldn't be a unique value
		end;
	end;
    return Iterators.IterateMap(t);
end;

local Suite = ReflectiveTestSuite:New("FritoMod_Collections.Iterators");

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

-- Tests that assert some non-intuitive or plain ambiguous behavior. These tests only assert
-- lua-specific functionality, so test failures indicate an incompatible lua version.

if nil ~= require then
	require "fritomod/ReflectiveTestSuite";
	require "fritomod/Assert";
	require "fritomod/Tests";
end;

local Suite = ReflectiveTestSuite:New("sanity");

local function Count(...)
	local total = select("#", ...);
	local nonNils = 0;
	for i=1, total do
		if select(i, ...) ~= nil then
			nonNils = nonNils + 1;
		end;
	end;
	return total, nonNils;
end;

function Suite:TestTableNewIndexFiresOnEveryNil()
	local f=Tests.Flag();
	local t=setmetatable({}, {
		__newindex=function(self,k,v)
			f.Raise();
			rawset(self,k,v);
		end
	});
	t.a=true;
	f.Unset();
	t.a=nil;
	f.AssertUnset("newindex must not be fired on deleted indices");
	t.a=true;
	f.Assert("newindex is fired on setting nil indices, even if they're not completely new");
end;

function Suite:TestStringSub()
	Assert.Equals("BC", ("ABC"):sub(2));
end;

function Suite:TestRemoveIsSane()
    local a = {"a", "b", "c"};
    Assert.Equals("a", table.remove(a, 1));
    Assert.Equals("b", table.remove(a, 1));
    Assert.Equals("c", table.remove(a, 1));
end;

function Suite:TestPairsIteratesEverything()
	local a={true,false,true};
	local c={};
	for k,v in pairs(a) do
		c[k]=v;
	end;
	Assert.Equals(a,c);
end;

function Suite:TestZeroIsTruthy()
	assert(0 or false);
end;

function Suite:TestOneToOneForLoopIteratesOnce()
	local f=Tests.Flag();
	for i=1,1 do
		f:AssertUnset("Loop only loops once");
		f:Raise();
	end;
	f:Assert("Flag was raised");
end;

function Suite:TestMaxn()
    if luaversion() >= luaversion("Lua 5.2") then
        -- table.maxn was removed in Lua 5.2
        return;
    end;
	local t = {};
	table.insert(t, true);
	table.insert(t, true);
	table.insert(t, true);
	Assert.Equals(3, table.maxn(t));
	t[2] = nil;
	Assert.Equals(3, table.maxn(t));
	t[4] = true;
	table.remove(t,4);
	Assert.Equals(3, table.maxn(t));
end;

function Suite:TestNewProxy()
    if luaversion() >= luaversion("Lua 5.2") then
        -- newproxy() was removed in Lua 5.2
        return;
    end;
	local p=newproxy(true);
	local mt=getmetatable(p);
	mt. __newindex = function(self, key, value)
		print(key);
	end
	mt.__len = function()
		return 3;
	end;
	local c={};
	for i=1,#p do
		table.insert(c, i);
	end;
	Assert.Equals({1,2,3},c);
end

function Suite:TestSparseArray()
	local list = {nil, nil, nil};
	list[3] = true;
	Assert.Equals(3, #list, "Sparse array retains size");
end;

function Suite:TestVarargsSizeIsConstant()
	Assert.Equals(2, Count(nil, nil), "Varargs retains size in spite of nil values");
end;

function Suite:TestSparseArrayIsWipedOutDuringRemoval()
	local list = {nil, nil, nil};
	list[3] = true;
	list[2] = true;
	table.remove(list, 3);
	Assert.Equals(0, #list, "Sparse array's size is lost due to table.remove");
end;

function Suite:TestUnpackWithNils()
	local total, nonNils = Count(unpack({nil, 2}));
	Assert.Equals(2, total, "Unpack unpacks correctly when array is of correct size");
	Assert.Equals(1, nonNils, "Unpack passes non-nil values");
end;

-- Demonstrates that intermediate nil values cause problems even if the array exists
-- almost entirely as a non-nil structure. They even cause problems if the array has
-- existed with only non-nil elements.
--
-- In other words, you simply never know what the length is if your array is sparse and
-- you're performing insertions or deletions.
function Suite:TestArrayLengthIsAbsurd()
	local inconsistencies = {};
	for insertions=1, 100 do
		for removalIndex=1, insertions do
			local list = {};
			for i=1, insertions do
				table.insert(list, true);
			end;
			list[removalIndex] = nil;
			if removalIndex == insertions and #list ~= insertions - 1 then
				table.insert(inconsistencies, {insertions, removalIndex, #list});
			elseif #list ~= insertions then
				table.insert(inconsistencies, {insertions, removalIndex, #list});
			end;
		end;
	end;
	assert(#inconsistencies > 0, "Array length is inconsistent");
end;

-- Demonstrates that even primed arrays still have inconsistencies with array length.
-- While investigating supporting nil values in Curry, I found out that {nil, nil, nil, ...}
-- seemed to preserve its length in most cases as long as the last element was not nil.
-- This turned out to be false, as this test case demonstrates. Specifically, things
-- start falling apart around 17 insertions, and never get any better. It essentially
-- approaches the inconsistencies found in the previous test case.
--
-- It may be possible that supporting sub-16 nil arguments in currying is possible, but
-- it seems to be about as error-prone as one can imagine to code, probably not anywhere
-- near performant, will never handle trailing nil values properly, and is a very rare use-
-- case anyway.
function Suite:TestAbsurdArrayLengthWithPrimedLengthTable()
	local inconsistencies = {};
	-- Changing the max intended length to 16 or lower will yield a failing test, meaning
	-- this strategy seems to work. Of course, this is only testing one nil value.
	for intendedLength=1, 100 do
		for removalIndex=1, intendedLength-1 do
			-- Creates a list that seems to be primed such that its length is more consistent
			-- than one created by table.insert alone.
			local code = ("return { %s }"):format(("true, "):rep(intendedLength));
			local list = assert(loadstring(code))();
			list[removalIndex] = nil;
			if #list ~= intendedLength then
				table.insert(inconsistencies, {insertions, removalIndex, #list});
			end;
		end;
	end;
	assert(#inconsistencies > 0, "Array length is still not consistent");
end;

function Suite:TestMetatableIsCalledOnTableInsertion()
	local t = {};
	local f = Tests.Flag();
	setmetatable(t, {
		__newindex = function(self, k, v)
			rawset(self, k, v);
			f:Raise();
		end
	});
	table.insert(t, "notime");
	if luaversion() >= luaversion("Lua 5.2") then
		f.AssertTrue("Metatable is used for insertion");
	else
		f.AssertFalse("Metatable is not used for insertion");
	end;
	Assert.Equals(1, #t, "Value is inserted into table");
end;

function Suite:TestCountdown()
	local t = {1,2,3,4};
	local c = {};
	for i=#t,1,-1 do
		table.insert(c, t[i]);
	end;
	Assert.Equals({4,3,2,1},c);
end;

do
    local g1, g2, g3;
    Suite:AddListener(Metatables.Noop({
        TestStarted = function(self, suite)
            g1 = __g1;
            g2 = __g2;
            g3 = __g3;
        end,
        TestFinished = function(self, suite)
            __g1 = g1;
            __g2 = g2;
            __g3 = g3;
        end
    }));
end;

function Suite:TestSetfenvHidesTrueGlobals()
    if luaversion() >= luaversion("Lua 5.2") then
        -- setfenv was removed in Lua 5.2
        return;
    end;

    local g = {};

    local trueGlobal = _G;
    local assert = assert;
    local function Test()
        __g1 = 42;
        assert(_G ~= trueGlobal, "_G must not refer to the true global table");
        assert(_G == nil, "_G must be nil unless otherwise specified");
    end;

    setfenv(Test, g);
    Test();
    Assert.Equals(42, g.__g1);
    Assert.Nil(__g1);
end;

function Suite:TestNestedFunctionsIgnoreSetfenv()
    if luaversion() >= luaversion("Lua 5.2") then
        -- setfenv was removed in Lua 5.2
        return;
    end;

    local grandchild = {};
    local function Grandchild()
        __g2 = "grandchild";
    end;
    -- I use setfenv here to ensure we don't pollute the global namespace, but
    -- the test is still valid if we omit this safety mechanism.
    --
    -- Specifically, functions invoked from a setfenv'd function will use their
    -- own environment; they will not inherit.
    setfenv(Grandchild, grandchild);

    local child = {};
    local function Child()
        __g1 = "child";
        Grandchild();
    end;
    setfenv(Child, child);

    Child();
    Assert.Equals("child", child.__g1);
    Assert.Nil(child.__g2);
    Assert.Equals("grandchild", grandchild.__g2);
end;

function Suite:TestNewFunctionsInheritSetfenvTable()
    if luaversion() >= luaversion("Lua 5.2") then
        -- setfenv was removed in Lua 5.2
        return;
    end;

    local child = {};

    local function Child()
        local function GrandChild()
            __g2 = "grandchild";
        end;
        __g1 = "child";
        GrandChild();
    end;
    setfenv(Child, child);
    Child();

    Assert.Nil(__g1);
    Assert.Equals("child", child.__g1);
    Assert.Nil(__g2);
    Assert.Equals("grandchild", child.__g2);
end;

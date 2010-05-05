-- Tests that assert some non-intuitive or plain ambiguous behavior. These tests only assert
-- lua-specific functionality, so test failures indicate an incompatible lua version.

if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";
end;

local Suite = ReflectiveTestSuite:New("FritoMod_SanityTests.sanity");

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

function Suite:PairsIteratesEverything()
	local a={true,false,true};
	local c={};
	for k,v in pairs(a) do
		c[k]=v;
	end;
	Assert.Equals(a,c);
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

function Suite:TestSparseArrayIsWipedOutDuringRemoval()
    local list = {nil, nil, nil};
    list[3] = true;
    list[2] = true;
    table.remove(list, 3);
    Assert.Equals(0, #list, "Sparse array's size is lost due to table.remove");
end;

function Suite:TestVarargsSizeIsConstant()
    Assert.Equals(2, Count(nil, nil), "Varargs retains size in spite of nil values");
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

function Suite:TestMetatableIsNotCalledOnTableInsertion()
	local t = {};
	local f = Tests.Flag();
	setmetatable(t, {
		__newindex = function(self, k, v)
			f:Raise();
		end
	});
	table.insert(t, "notime");
	f.AssertFalse("Metatable is not used for insertion");
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

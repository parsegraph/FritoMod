-- Lists provides a number of iteration functions for arrays. Most of the code
-- is actually found in Mixins.Iteration or Mixins.MutableIteration; Lists is
-- merely an implementation of that mixin.
--
-- All these functions work on, and are intended to work on,  plain old Lua
-- tables. You don't need to create some special object to use these methods.

if nil ~= require then
	require "fritomod/currying";
	require "fritomod/Functions";
	require "fritomod/Metatables";
	require "fritomod/Mixins-MutableIteration";
end;

Lists = {};
local Lists = Lists;

-- Iteration functionality for lists.
Mixins.MutableIteration(Lists);
Metatables.Defensive(Lists);

function Lists.Iterator(iterable)
	assert(type(iterable) == "table", "iterable is not a table");
	local index = 0;
	if #iterable == 0 then
		return Noop;
	end;
	return function()
		index = index + 1;
		if index > #iterable then
			return;
		end;
		return index, iterable[index];
	end;
end;

-- This implementation is provided solely for performance.
function Lists.ValueIterator(iterable)
	assert(type(iterable) == "table", "iterable must be a table");
	local i=0;
	local size=#iterable;
	return function()
		i = i + 1;
		if i > size then
			return nil;
		end;
		return iterable[i];
	end;
end;

-- This implementation is provided solely for performance.
function Lists.KeyIterator(iterable)
	assert(type(iterable) == "table", "iterable must be a table");
	local i=0;
	local size=#iterable;
	return function()
		i = i + 1;
		if i > size then
			return nil;
		end;
		return i;
	end;
end;

function Lists.Get(iterable, key)
	return iterable[key];
end;

function Lists.Next(iterable, i)
	if i==nil or i<1 then
		i=0;
	end;
	i=i+1;
	if iterable[i] then
		return i, iterable[i];
	end;
end;

function Lists.Previous(iterable, i)
	if i==nil or i<1 then
		i=0;
	end;
	i=i-1;
	if iterable[i] then
		return i, iterable[i];
	end;
end;

function Lists.Length(iterable)
	return #iterable;
end;
Lists.Size=Lists.Length;

function Lists.Insert(iterable, value)
	table.insert(iterable, value);
	return Seal(Functions.OnlyOnce(Lists.Remove, iterable, value));
end;

function Lists.Delete(iterable, key)
	return table.remove(iterable, key);
end;

do
	local super=Lists.Snippet;
	function Lists.Snippet(iterable, first, last, func, ...)
		if first~=nil and first<0 then
			first=#iterable-first;
		end;
		if last~= nil and last<0 then
			last=#iterable-last;
		end;
		first=math.max(first, 1);
		last=math.min(last, #iterable);
		return super(iterable, first, last, func, ...);
	end;
end;

--[[
-- Check where the specified iterable contains the specified target value. If
-- testFunc is provided, it will be used to determine equality. Otherwise, lua's
-- equality operator will be used.
--
-- testFunc should expect an element from the iterable as its first argument and
-- the specified target as its second. Any truthy value will be interpreted as a
-- "equal" result.
--
-- ContainsValue will return true if any element is found equal to target, otherwise
-- it will return false.
--]]
function Lists.ContainsValue(iterable, target, testFunc, ...)
	if testFunc then
		testFunc=Curry(testFunc, ...);
	end;
	for i=1,#iterable do
		if testFunc then
			if testFunc(iterable[i], target) then
				return true;
			end;
		elseif target==iterable[i] then
			return true;
		end;
	end;
	return false;
end;

function Lists.ContainsKey(iterable, target, testFunc, ...)
	if not testFunc then
		return type(target)=="number" and target>=1 and target <=#iterable;
	end;
	testFunc=Curry(testFunc, ...);
	for i=1, #iterable do
		if testFunc(iterable[i], target) then
			return true;
		end;
	end;
	return false;
end;

function Lists.CallEach(iterable, ...)
	for i=1, #iterable do
		iterable[i](...);
	end;
end;

-- Cursors.Iterable provides a view over an array. It offers a way to efficiently navigate an array's elements
-- without needing to wrap that array in some object. Users provide the iterable and an optional library for
-- iteration. This allows this class to be used by any iterable. Strings and Lists already provide the necessary
-- methods.

-- What separates cursors from iterators is their intelligence. Cursors provide useful methods to keep your code
-- readable. A cursor is designed to be reused quickly, so you don't have to worry about inefficient object creation.
-- They provide a good trade-off between an object-heavy world and the functional one that FritoMod likes to live in.

-- I feel like a bit of code demonstrates the usefulness of a cursor. Here's an example of splitting a string into
-- words:
--
-- local s="The Comanche moon was a portent for disaster";
-- local c=Cursors.Iterable:New(s); -- (1)
-- local parts={};
-- while c:MoveUntil(Strings.IsLetter) do  -- (2)
--	 c:Mark(); -- (3)
--	 c:PeekWhile(Strings.IsLetter); -- (4)
--	 table.insert(parts, c:MarkSnippet()); -- (5)
-- end;
-- Assert.Equals(Strings.Split(" ", s), parts);
--
-- (1) - A cursor is an object, in the official OOP.Class sense of the word. The constructor takes an iterable value.
-- Arrays and strings are currently accepted, though custom iterables are allowed by providing a library.
-- (2) - This while-loop starts by iterating over non-letter characters. MoveUntil returns false if it reaches the end
-- of the string. Otherwise, MoveUntil will stop on the first letter.
-- (3) - Mark tells the cursor to remember its position. We could save the position ourselves in a local variable.
-- (4) - PeekWhile is similar to MoveUntil, in that iterates based on the passed function. However, peek will ignore its
-- current location, and only look to the next one. It will move only if the next location is a letter. Peek lets us move
-- to the end of the word without going past it.
-- (5) - MarkSnippet creates a substring using our saved mark and our current location. This retrieves the word.
--
-- I really like this clarity. Move, Peek, and Sneak really let us express what we want. For comparison, here's a naive
-- version that I wrote:
--
-- local s="The Comanche moon was a portent for disaster";
-- local parts={};
-- local startOfWord;
-- for i=1,#s do
--	 local isLetter=Strings.IsLetter(Strings.CharAt(s, i));
--	 if not startOfWord then
--		 startOfWord=i;
--	 elseif not isLetter then
--		 table.insert(parts, s:sub(startOfWord, i-1));
--		 startOfWord=nil;
--	 end;
-- end;
-- if startOfWord then
--	 table.insert(parts, s:sub(startOfWord));
-- end;
-- Assert.Equals(Strings.Split(" ", s), parts);

-- Our three strategies can be confusing to differentiate, so I wrote up this to help others (and myself) out.
--
-- * Move: Move then check. Move always moves at least once.
-- * Sneak: Check then move.
-- * Peek: Check next then move.
--
--   Sneak checks where it's standing before it can move.  It's also short-sighted - it needs to stand on a
-- place before it can check it.
--   Move is similar to Sneak, but it moves before it starts checking. Move is sloppy: it can be standing
-- in bad stuff -and- jump into more bad stuff.
--   Peek doesn't jump into bad stuff, so it's learned from the messier Move, but it doesn't check where it
-- starts at. It's the "safest" iterator: if it starts in good stuff, it will always end in good stuff.
--
-- These all differ by their starting and ending behavior. In the middle, they all are checking and moving
-- in basically the same way.
-- to some degree. No strategy can survive two consecutive bad elements. Strategies can end up past the start
-- or ends, but never by more than one.
--
--	   BB BG GB GG GGB
-- Sneak *  *  =* == ==*
-- Peek  *  -= *  -= -*
-- Move  -* -= -* -= -=*
--
-- - - Skipped past this element
-- = - Checked and moved past this element
-- * - Died here.
--
-- You don't need to use these methods, of course. Plain function calls, combined with Next will always work. However, in
-- this case, your clarity will probably be similar to the naive method.

if nil ~= require then
	require "fritomod/currying";
	require "fritomod/OOP-Class";
	require "fritomod/Strings";
	require "fritomod/Lists";
	require "fritomod/Tables";
end;
Cursors=Cursors or {};

Cursors.Iterable=OOP.Class();
local cursor=Cursors.Iterable;

function cursor:Constructor(iterable, library)
	assert(iterable ~= nil, "No iterable was provided");
	self:Iterable(iterable, library);
end;

function cursor:Iterable(iterable, library)
	if iterable ~= nil then
		self.iterable=iterable;
		if not library then
			if type(iterable)=="string" then
				library=Strings;
			elseif type(iterable)=="table" then
				if #iterable then
					library=Lists;
				else
					library=Tables;
				end;
			elseif self.library then
				-- We'll use the current library if we have one and couldn't guess at a better one.
				-- We may want to make this be our first option, but I don't have a use-case yet.
				library=self.library;
			else
				error("Unrecognized "..type(iterable).." iterable: "..tostring(iterable));
			end;
		end;
		self.library=library;
		self.index=0;
		self.mark=nil;
	end
	return self.iterable;
end;
cursor.GetIterable=cursor.Iterable;

function cursor:Clone()
	local clone=Cursors.Iterable:New(self.iterable, self.library);
	clone.index=self.index;
	clone.mark=self.mark;
	return clone;
end;

function cursor:Next()
	local k,v=self.library.Next(self.iterable, self.index);
	if k ~= nil then
		self.index=k;
	else
		self.index=self:Length()+1;
	end;
	return k,v;
end;
cursor.Forward=cursor.Next;

function cursor:Previous()
	local k,v=self.library.Previous(self.iterable, self.index);
	if k ~= nil then
		self.index=k;
	else
		self.index=0;
	end;
	return k,v;
end;
cursor.Backward=cursor.Previous;
cursor.Back=cursor.Previous;

function cursor:Get()
	if self:AtValid() then
		return self.library.Get(self.iterable, self.index);
	end;
end;
cursor.Value=cursor.Get;
cursor.GetValue=cursor.Get;

function cursor:Index()
	if self:AtValid() then
		return self.index;
	end;
end;
cursor.Key=cursor.Index;
cursor.Position=cursor.Index;
cursor.Offset=cursor.Index;
cursor.Location=cursor.Index;

function cursor:Pair()
	return self:Index(), self:Get();
end;

function cursor:To(i)
	self.index=math.max(0, math.min(self:Length()+1, i));
	if self:AtValid() then
		return self.index;
	end;
end;

function cursor:Length()
	return self.library.Length(self.iterable);
end;
cursor.Size=cursor.Length;

function cursor:AtStart()
	return self.index<=1;
end;
cursor.AtBeginning=cursor.AtStart;

function cursor:ToStart()
	self.index=0;
end;
cursor.ToBeginning=cursor.ToStart;

function cursor:AtEnd()
	return self.index>=self.library.Length(self.iterable);
end;

function cursor:ToEnd()
	self.index=self:Length()+1;
end;

function cursor:AtValid()
	return self.index>0 and self.index<=self:Length();
end;

function cursor:Move(steps)
	steps=steps or 1;
	return self:To(self.index + steps);
end;

function cursor:Peek(steps)
	if steps==nil then
		steps=1;
	end;
	local oldIndex=self.index;
	local sneakedIndex=self:Move(steps);
	local v=self:Get();
	self:To(oldIndex);
	return v, sneakedIndex;
end;
cursor.PeekNext=Headless("Peek", 1);
cursor.PeekPrevious=Headless("Peek", -1);

local function MoveWhile(self, steps, func, ...)
	func=Curry(func, ...);
	while true do
		self:Move(steps);
		local k,v=self:Pair();
		if k==nil or not func(v, k) then
			return k~=nil;
		end;
	end;
	return false;
end;

local function MoveUntil(self, steps, func, ...)
	func=Curry(func, ...);
	return MoveWhile(self, steps, function(v, k)
		return not func(v, k);
	end);
end;

local function SneakWhile(self, steps, func, ...)
	func=Curry(func, ...);
	while true do
		local k,v=self:Pair();
		if k==nil or not func(v, k) then
			return k~=nil;
		end;
		self:Move(steps);
	end;
	return false;
end;

local function SneakUntil(self, steps, func, ...)
	func=Curry(func, ...);
	return SneakWhile(self, steps, function(v, k)
		return not func(v,k);
	end);
end;

local function PeekWhile(self, steps, func, ...)
	func=Curry(func, ...);
	while true do
		local v, k=self:Peek(steps);
		if k==nil or not func(v, k) then
			return k~=nil;
		end;
		self:Move(steps);
	end;
	return false;
end;

local function PeekUntil(self, steps, func, ...)
	func=Curry(func, ...);
	return PeekWhile(self, steps, function(v, k)
		return not func(v,k);
	end);
end;

cursor.NextWhile		 =Headless(MoveWhile,   1);
cursor.PreviousWhile	 =Headless(MoveWhile,  -1);
cursor.NextUntil		 =Headless(MoveUntil,   1);
cursor.PreviousUntil	 =Headless(MoveUntil,  -1);

cursor.MoveWhile		 =Headless(MoveWhile,   1);
cursor.MoveUntil		 =Headless(MoveUntil,   1);
cursor.MoveNextWhile	 =Headless(MoveWhile,   1);
cursor.MovePreviousWhile =Headless(MoveWhile,  -1);
cursor.MoveNextUntil	 =Headless(MoveUntil,   1);
cursor.MovePreviousUntil =Headless(MoveUntil,  -1);

cursor.PeekWhile		 =Headless(PeekWhile,   1);
cursor.PeekUntil		 =Headless(PeekUntil,   1);
cursor.PeekNextWhile	 =Headless(PeekWhile,   1);
cursor.PeekPreviousWhile =Headless(PeekWhile,  -1);
cursor.PeekNextUntil	 =Headless(PeekUntil,   1);
cursor.PeekPreviousUntil =Headless(PeekUntil,  -1);

cursor.SneakWhile		=Headless(SneakWhile,  1);
cursor.SneakUntil		=Headless(SneakUntil,  1);
cursor.SneakNextWhile	=Headless(SneakWhile,  1);
cursor.SneakPreviousWhile=Headless(SneakWhile, -1);
cursor.SneakNextUntil	=Headless(SneakUntil,  1);
cursor.SneakPreviousUntil=Headless(SneakUntil, -1);

function cursor:Mark()
	if self:AtValid() then
		self.mark=self.index;
		return self.mark;
	end;
end;

function cursor:MarkNext()
	if self:Next() ~= nil then
		self.mark=self.index;
		return self.mark;
	end;
end;

function cursor:Reset()
	if self.mark then
		self.index=self.mark;
		self.mark=nil;
		return self.index;
	else
		self.index=0;
		return;
	end;
end;

function cursor:Snippet(first, last)
	if last==nil then
		last=first;
		first=nil;
	end;
	if first==nil then
		first=1;
		last=self.index;
	end;
	return self.library.Snippet(self.iterable, first, last);
end;

function cursor:MarkSnippet(other)
	if self.mark==nil then
		return self:Snippet(other);
	end;
	if other==nil then
		other=self.index;
	end;
	return self.library.Snippet(self.iterable, self.mark, other);
end;

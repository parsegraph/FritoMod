-- Serializes Lua data into a compressed string.
--[[

-- /ntg hello, world!

function Slash.ntg(what)
   local msg = {
	  message = tostring(what),
	  who = GetUnitName("player"),
	  when = time()
   };
   Remote["ntg"].g(Serializers.WriteStringChunks(
		 Serializers.WriteData(msg),
   "ntg"));
end;

Callbacks.StringChunks(Remote["ntg"], function(msg)
	  msg = Serializers.ReadData(msg);
	  printf("%s said %q", msg.who, msg.message);
end);

--]]

if nil ~= require then
	require "fritomod/Metatables";
	require "fritomod/Cursors-Iterable";
end;

Serializers=Serializers or {};
local Read, Write;

local writers=Metatables.Defensive({
	boolean=function(b)
		if b==true then
			return "B";
		end;
		return "b";
	end,

	string=function(s)
		if s=='' then
			return "S";
		end;
		return ("s%d%s"):format(#s, s);
	end,

	number=function(n)
		if n % 1 == 0 then
			return ("n%d"):format(n);
		end;
		return ("n%f"):format(n);
	end,

	["function"]=function(f)
		return Write(f());
	end,

	["nil"]=function()
		return "_";
	end,

	table=function(t)
		local out="t";
		for k,v in pairs(t) do
			out=out..("k%s%s"):format(
				Write(k),
				Write(v)
			);
		end;
		return out;
	end
});

Write=function(v)
	return writers[type(v)](v);
end;

function Serializers.WriteData(...)
	local out="";
	for i=1,select("#", ...) do
		local v=select(i, ...);
		out=out..Write(v);
	end;
	return out;
end;

local readers=Metatables.Defensive();

function readers.B(c)
	return c:Get()=="B";
end;
readers.b=readers.B;

function readers.s(c)
	c:MarkNext(); -- Skip the 's'
	c:PeekWhile(Strings.IsNumber);
	local len=tonumber(c:MarkSnippet());
	c:MarkNext();
	c:Move(math.max(0, len-1));
	return c:MarkSnippet();
end;

function readers.S(c)
	return '';
end;

function readers._(c)
	return nil;
end;

function readers.n(c)
	c:Next(); -- Skip the 'n'
	local number=c:Iterable():match("-?%d+%.?%d*", c:Index());
	c:Move(#number-1);
	return tonumber(number);
end;

function readers.t(c)
	trace("Reading table");
	c:Next() -- Skip the 't'
	local t={};
	while c:Get()=="k" do
		c:Next();
		local k=Read(c);
		trace("Reading key %q", tostring(k));
		c:Next();
		local v=Read(c);
		trace("Reading value %q", tostring(v));
		t[k]=v;
		c:Next();
	end;
	return t;
end;

-- Version. We allow this to be anywhere in the string, but we
-- usually just ignore it.
function readers.v(c)
	c:Next() -- Skip the 'v'
	c:PeekWhile(Strings.IsNumber);
	return Read(c);
end;

function readers.l(c)
	c:MarkNext(); -- Skip the 'l'
	local t={};
	c:PeekWhile(Strings.IsNumber);
	local len=tonumber(c:MarkSnippet());
	for i=1,len do
		table.insert(t, Read(c));
	end;
	return t;
end;

Read=function(c)
	local dataType = c:Get();
	trace("Reading next value %q", dataType);
	return readers[dataType](c);
end;

function Serializers.ReadData(c)
	if not OOP.InstanceOf(Cursors.Iterable, c) then
		c=Cursors.Iterable:New(c);
	end;
	local data={};
	while c:Next() do
		table.insert(data, Read(c));
	end;
	return unpack(data);
end;

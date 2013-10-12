-- Serializes Lua objects into source code that represents them.
--[[

local t = {
	foo = "Notime",
	bar = {
		baz = "Hello!",
		num = 42
	}
};

local retrieved = Serializers.ReadSource(Serializers.WriteSource(t));

assert(retrieved.foo == "Notime");
assert(retrieved.bar.baz == "Hello!");
assert(retrieved.bar.num == 42);

--]]
-- This serializer will convert Lua primitives and tables into
-- a string that, when executed by the Lua interpreter, will reproduce
-- the original string.
--
-- This class is useful if you want to save Lua data to disk while still
-- keeping it human-readable. While it's suitable to be sent over a
-- network connection, its representation is not very efficient. You should
-- use Serializers.Data for serialization over a network.
--
-- See Also:
-- Serializers-Data.lua

if nil ~= require then
	require "fritomod/Metatables";
	require "fritomod/Cursors-Iterable";
end;

Serializers=Serializers or {};

local printer;
printer=setmetatable({
	["number"]=function(out, v)
		if v % 1 == 0 then
			out(("%d"):format(v));
		else
			out(("%f"):format(v));
		end;
	end,
	["boolean"]=function(out, v)
		out(tostring(v));
	end,
	["string"]=function(out, v)
		out(("%q"):format(v));
	end,
	["nil"]=function(out)
		out("nil");
	end,
	["table"]=function(out, t, newline)
		local indent="\t";
		local indented=newline..indent;
		out("{");
		out(newline);
		local i=1;
		local arrayKeys={};
		while t[i] ~= nil do
			arrayKeys[i]=true;
			out(indent);
			printer(out, t[i], indented);
			out(",");
			out(newline);
			i=i+1;
		end;
		local iteratedNumbers={};
		local iteratedStrings={};
		for k,v in pairs(t) do
			if type(k)=="number" then
				if arrayKeys[k] then
					-- do nothing
				else
					table.insert(iteratedNumbers, k);
				end;
			else
				table.insert(iteratedStrings, k);
			end;
		end;
		table.sort(iteratedNumbers);
		table.sort(iteratedStrings);
		local function PrintPair(k)
			out(indent);
			out("[");
			printer(out, k, indented);
			out("] = ");
			printer(out, t[k], indented);
			out(",");
			out(newline);
		end;
		for _, k in ipairs(iteratedNumbers) do
			PrintPair(k);
		end;
		for _, k in ipairs(iteratedStrings) do
			PrintPair(k);
		end;
		out("}");
	end,
    ["unknown"] = function(out, v)
        out("nil --[["..type(v).."]]");
    end
}, {
	__index=function(self, k)
		return self["unknown"];
	end,
	__call=function(self, out, v, newline)
		newline=newline or "\n";
		return self[type(v)](out, v, newline);
	end
});

function Serializers.WriteSource(v, out, ...)
	if out or select("#", ...) > 0 then
		out=Curry(out, ...);
		return printer(out, v);
	else
		local str="";
		printer(function(s)
			s=tostring(s);
			str=str..s;
		end, v);
		return str;
	end;
end;

function Serializers.ReadSource(str)
	local producer;
	if _VERSION == "Lua 5.1" then
        producer = assert(loadstring("return " .. str));
    else
        producer = assert(load("return " .. str));
	end;
	return producer();
end;

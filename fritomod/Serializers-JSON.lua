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
        out("null");
    end,
    ["table"]=function(out, t, newline)
        local indent="\t";
        local indented=newline..indent;

        local i = 1;
        local arrayKeys = {};
        while t[i] ~= nil do
            arrayKeys[i]=true;
            i=i+1;
        end;
        local numericKeys={};
        local stringKeys={};
        for k,v in pairs(t) do
            if arrayKeys[k] then
                -- Ignore array keys; these are already accounted for
            elseif type(k) == "number" then
                table.insert(numericKeys, k);
            elseif type(k) == "string" then
                table.insert(stringKeys, k);
            end;
        end;

        if #numericKeys == 0 and #stringKeys == 0 and #arrayKeys > 0 then
            -- It's just an array
            out("[");
            out(newline);
            local first = true;
            for key, _ in pairs(arrayKeys) do
                if not first then
                    out(",");
                    out(newline);
                end;
                first = false;

                out(indent);
                printer(out, t[key], indented);
            end;
            out(newline);
            out("]");
            return;
        end;

        if #numericKeys == 0 and #stringKeys == 0 then
            out("{}");
            return;
        end;

        table.sort(numericKeys);
        table.sort(stringKeys);

        local first = true;
        local function PrintPair(k)
            if not first then
                out(",");
                out(newline);
            end;
            first = false;

            out(indent);
            printer(out, tostring(k), indented);
            out(" : ");
            printer(out, t[k], indented);
        end;

        out("{");
        out(newline);
        for _, key in ipairs(numericKeys) do
            PrintPair(key);
        end;
        for _, key in ipairs(stringKeys) do
            PrintPair(key);
        end;
        out(newline);
        out("}");
    end,
    ["unknown"] = function(out, v)
        printer(out, type(v));
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

function Serializers.WriteJSON(v, out, ...)
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

function Serializers.ReadJSON(str)
    error("Not yet implemented");
end;

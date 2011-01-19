if nil ~= require then
    require "Metatables";
    require "Cursors-Iterable";
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
        out(v);
    end,
    ["string"]=function(out, v)
        out(("%q"):format(v));
    end,
    ["nil"]=function(out)
        out(v);
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
            out(", -- [");
            out(i);
            out("]");
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
    end
}, {
    __index=function(self, k)
        error("Unexpected type: "..k);
    end,
    __call=function(self, out, v, newline)
        newline=newline or "\n";
        return self[type(v)](out, v, newline);
    end
});

function Serializers.WriteLua(v, out, ...)
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

function Serializers.ReadLua(str)
    return loadstring(str);
end;

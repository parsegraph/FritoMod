if nil ~= require then
    require "basic";
    require "currying";
    require "Strings-Transform";
end;

-- Chatpics.fail(Chat.g);
-- Chatpics.sets.mark("0101010101", Chat.g);

local sets=setmetatable({}, {
    __index=function(self, k)
        if IsCallable(k) then
            return self[k()];
        end;
        return rawget(self, tostring(k):lower());
    end,
    __newindex=function(self, k, set)
        k=tostring(k):lower();
        assert(type(set)=="table", "Set must be a table");
        local mt=getmetatable(set);
        if not mt then
            mt={};
            setmetatable(set, mt);
        end;
        mt.__call=function(str, out, ...)
            out=Curry(out, ...);
            out(Strings.Transform(set, str));
        end;
        rawset(self, k, set);
    end
});

Chatpic=setmetatable({}, {
    __index=function(self, k)
        if type(k)=="function" then
            return self[k()];
        elseif type(k)=="table" then
            return function(output, ...)
                output=Curry(output, ...);
                for i=1, #k do
                    self[k[i]](output);
                end;
            end;
        else
            assert(k, "key was falsy");
            k=tostring(k):lower();
        end;
        return rawget(self, k);
    end,
    __newindex=function(self, k, picture)
        k=tostring(k):lower();
        rawset(self, k, function(out, ...)
            out=Curry(out, ...);
            out(Strings.Transform(picture.set, picture));
        end);
    end
});

rawset(Chatpic, "set", sets);
rawset(Chatpic, "sets", sets);

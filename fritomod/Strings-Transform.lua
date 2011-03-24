if nil ~= require then
    require "Strings";
    require "Unicode";
    require "Lists";
end;

function Strings.Transform(str, set)
    if type(str)=="function" then
        return Strings.Transform(str(), set);
    end;
    if type(str)=="table" then
        return Lists.Map(str, Headless(Strings.Transform, set));
    end;
    str=str:gsub(".", function(c)
        local converted=set[c];
        if not converted then
            return c;
        end;
        if type(converted)=="number" then
            return Unicode[converted];
        end;
        return converted;
    end);
    return str;
end;


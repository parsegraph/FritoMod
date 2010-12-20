-- Chatpic lets us print out obnoxious pictures using raid icons.
--
-- Specifically, it provides a place for pictures and sets. Pictures
-- are tables of strings that describe an image. The symbols that the
-- picture uses are interpreted by the set. For example:
--
-- Chatpic.set.banner={
--     ["_"]="{square}",
--     ["0"]="{circle}",
-- };
--
-- Chatpic.banner={
--     "_0_0_0_0_",
--     set="banner"
-- };
--
-- Chatpic.banner(Chat.g);
--
-- This describes a simple one-line picture. This will print a line of alternating
-- square and circle raid marks to your guild. The _ and 0 will be converted according
-- to the provided set. Characters that aren't in the set will be printed directly.
--
-- We don't need to provide a picture if we have a set. In the above case, we could
-- also do this:
-- 
-- Chatpic.set.banner("_0_0_0_0_", Chat.g);
--
-- which will yield the same result.
-- 
-- Most of Chatpic's grunt work is actually done by String.Transform. Chatpic just provides
-- a place to store sets and pictures, along with some metatable magic to make it convenient
-- to use. To continue our example, we could have just done this:
-- 
-- Chat.g(String.Transform(Chatpic.set.banner, "_0_0_0_0_"));
--
-- which also prints the same thing.
--
-- Chatpic doesn't come with a slash command, though it would be easy to provide one.
--
-- Slash.Register("cp", function(msg, editbox)
--     Chatpic[msg](Chat[editbox]);
-- end);
-- 
-- Which will print the "fail" picture to whatever medium you're using, such as guild, party, etc.

if nil ~= require then
    require "basic";
    require "currying";
    require "Strings-Transform";
end;

local function OutputTransform(set, picture, out, ...)
    out=Curry(out, ...);
    local transformed=Strings.Transform(set, picture);
    if type(transformed)=="table" then
        for i=1,#transformed do
            out(transformed[i]);
        end;
    else
        out(transformed);
    end;
end;

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
        -- Calling a set lets you write using that set's transformations.
        mt.__call=function(self, str, out, ...)
            OutputTransform(set, str, out, ...);
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
        if IsCallable(picture) then
            rawset(self, k, picture);
        else
            local mt=getmetatable(picture);
            if not mt then
                mt={};
                setmetatable(picture, mt);
            end;
            -- Calling a picture draws that picture using the provided output function.
            mt.__call=function(self, out, ...)
                local set=picture.set;
                if type(picture.set)~="table" then
                    set=assert(Chatpic.set[picture.set], "Not a valid set name: "..tostring(picture.set));
                end;
                OutputTransform(set, picture, out, ...);
            end;
            rawset(self, k, picture);
        end;
    end
});

rawset(Chatpic, "set", sets);
rawset(Chatpic, "sets", sets);

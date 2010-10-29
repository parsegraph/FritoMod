if nil ~= require then
    require "basic";
    require "currying";
    require "Metatables";
    require "Unicode";
end;

local pictures={};
pictures.fail={
    "_______________",
    "_000__0__0_0___",
    "_0___0_0_0_0___",
    "_00__000_0_0___",
    "_0___0_0_0_0___",
    "_0___0_0_0_000_",
    "_______________",
    set="mark"
};

local sets=Metatables.CoercingKey({}, string.lower);
sets.marks={
    ["_"] = "{square}",
    ["0"] = "{skull}",
    ["1"] = "{x}",
    ["2"] = "{circle}",
    ["3"] = "{triangle}",
    ["4"] = "{diamond}",
    ["5"] = "{star}",
    ["6"] = "{moon}",
};
sets.raidmarks=sets.marks;
sets.rm=sets.marks;
sets.mark=sets.mark;

sets.blocks={
    ["_"] = 75,
    ["0"] = 72
};
sets.block=sets.blocks;

local function Draw(name, output, ...)
    output=Curry(output, ...);
    local picture=pictures[name];
    local Transform=
        picture.Transform or
        picture.transform or
        picture.Convert or
        picture.convert or
        picture.Set or
        picture.set or
        picture.Conversions or
        picture.conversions;
    if not IsCallable(Transform) then
        local conversions=Transform;
        if sets[conversions] then
            conversions=sets[conversions];
        else
            conversions={};
        end;
        Transform=function(line)
            line:gsub(".", function(c)
                local converted=conversions[c];
                if not converted then
                    return c;
                end;
                if type(converted)=="number" then
                    return Unicode[converted];
                end;
                return converted;
            end);
        end;
    end;
    for _, line in ipairs(picture) do
        output(Transform(line));
    end;
end;

Chatpic={};
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
        assert(pictures[k], "No picture with the name: "..k);
        return Seal(Draw, k);
    end,
    __newindex=function(self, k, v)
        k=tostring(k):lower();
        pictures[k]=v;
    end
});

Chatpic.sets=sets;
Chatpic.Sets=sets;

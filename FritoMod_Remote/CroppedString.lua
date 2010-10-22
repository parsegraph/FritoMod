if nil ~= require then
    require "FritoMod_Functional/basic";
    require "FritoMod_Serialize/Serializers";
end;

Callbacks=Callbacks or {};

local MAX_MESSAGE_SIZE=254;
local chunkGroup=0;

function Serializers.WriteCroppedString(str, prefix)
    if IsCallable(str) then
        return Serializers.WriteCroppedString(prefix, str());
    elseif type(str)=="table" then
        if #str==1 then
            return Serializers.WriteCroppedString(str[1]);
        end;
        local strings={};
        for i=1, #str do
            local v=Serializers.WriteCroppedString(str[i]);
            if type(v)=="table" then
                Lists.InsertAll(strings, v);
            else
                table.insert(strings, v);
            end;
        end;
        return strings;
    elseif not IsPrimitive(str) then
        error("Unsupported "..type(str).." value: "..tostring(str));
    end;
    while type(prefix)~="number" do
        if IsCallable(prefix) then
            prefix=prefix();
        elseif IsPrimitive(prefix) then
            prefix=#tostring(prefix);
        elseif prefix==nil then
            prefix=0;
        else
            error("Unsupported "..type(prefix).." value: "..tostring(prefix));
        end;
    end;
    local chunkSize=MAX_MESSAGE_SIZE-prefix;
    if #str + 2 <= chunkSize then
        -- We only need one chunk to create our message.
        return "0:"..str;
    else
        -- We need many chunks to create our messages.
        chunkGroup=chunkGroup+1;
        local chunkPrefix=chunkGroup..":";
        local strings={};
        for i=1,#str,chunkSize do
            table.insert(strings, chunkPrefix..str:sub(i, i+chunkSize-1));
        end;
        return strings;
    end;
end;

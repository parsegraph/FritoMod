if nil ~= require then
    require "FritoMod_Collections/Tables";
end;

local mediums={};

mediums.party="party";
Tables.Alias(mediums, "party", "p", "par");

mediums.guild="guild";
Tables.Alias(mediums, "guild", "g");

mediums.raid="raid";
Tables.Alias(mediums, "raid", "r", "ra");

mediums.battleground="battleground";
Tables.Alias(mediums, "battleground", "battlegroup", "bg", "pvp");

local function SendMessage(medium, prefix, msg)
    if mediums[medium] then
        if ChatThrottleLib then
            ChatThrottleLib:SendAddonMessage("NORMAL", prefix, msg, medium);
        else
            SendAddonMessage(prefix, msg, medium);
        end;
    else
        if ChatThrottleLib then
            ChatThrottleLib:SendAddonMessage("NORMAL", prefix, msg, "WHISPER", medium);
        else
            SendAddonMessage(prefix, msg, "WHISPER", medium);
        end;
    end;
end;

Remote=setmetatable({}, {
    __index=function(self, prefix)
        self[prefix]=setmetatable({
            __index=function(self, medium)
                assert(type(medium)=="string", "medium must be a string");
                medium=medium:lower();
                self[medium]=function(msg)
                    return SendMessage(medium, msg);
                end;
                return self[medium];
            end,
            __call=function(func, ...)
                func=Curry(func, ...);
                return Events.CHAT_MSG_ADDON(function(msgPrefix, message, medium, source)
                    if prefix~=msgPrefix then
                        return;
                    end;
                    func(source, message);
                end);
            end
        });
        return self[prefix];
    end
});

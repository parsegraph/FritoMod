-- Remote lets you listen for and dispatch remote events.
--
-- Slash.Register("notime", Remote["NoTime.Chat"].g);
-- Remote["NoTime.Chat"](function(who, message)
--     print(("%s said %q"):format(who, message));
-- end);
--
-- /notime Hello, everyone!
--
-- Remote does no serialization, so it doesn't accept non-primitive values. I'm a 
-- little torn on whether to include a built-in serializer. Not including one limits
-- the usefulness of this solution and generates errors in situations where you wouldn't
-- anticipate them.
--
-- I'm still against the idea because including a serializer means that using Remote locks
-- people into FritoMod. People with foreign serializing solutions would be out of luck.
-- 
-- Plus, it seems easy to just write parsers separately and call them explicitly. We can do
-- some metatable/closure magic to retain the original syntax.
-- 
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
        self[prefix]=setmetatable({}, {
            __index=function(self, medium)
                assert(type(medium)=="string", "medium must be a string");
                medium=medium:lower();
                self[medium]=function(...)
                    assert(select("#", ...)==1 and tostring(select(1, ...)), 
                        "Remote does not accept non-string values");
                    return SendMessage(medium, ...);
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

-- Remote lets you listen for and dispatch remote events.
--
-- Slash.notime = Remote["g:NoTime.Chat"];
-- Remote["g:NoTime.Chat"](function(message, who)
--	 print(("%s said %q"):format(who, message));
-- end);
--
-- /notime Hello, everyone!
--
-- Remote does no serialization, so it doesn't translate anything other than strings.
--
-- I'm a little torn on whether to include a built-in serializer. Not including one limits
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
	require "fritomod/basic";
	require "fritomod/Tables";
end;

assert(not Remote, "Remote must not already exist");
Remote = {};

local listenerMap = {};

function Remote:Dispatch(channel, ...)
    local listeners = listenerMap[channel];
    if listeners then
        listeners:Fire(...);
    end;
end;

setmetatable(Remote, {
    __index = function(self, channel)
        local listeners = ListenerList:New();
        listeners:AddInstaller(Remote, "Install", channel);
        listenerMap[channel] = listeners;
        rawset(Remote, channel, Curry(listeners, "Add"));
        return self[channel];
    end
});

local mediums={};

mediums.party="party";
Tables.Alias(mediums, "party", "p", "par");

mediums.guild="guild";
Tables.Alias(mediums, "guild", "g");

mediums.raid="raid";
Tables.Alias(mediums, "raid", "r", "ra");

mediums.battleground="battleground";
Tables.Alias(mediums, "battleground", "battlegroup", "bg", "pvp");

function GetMediumAndPrefix(channel)
    if channel:find(":") then
        return unpack(Strings.Split(":", channel, 2));
    end;
    return nil, channel;
end;

function GetChannel(medium, prefix)
    return medium .. ":" .. prefix;
end;

function Remote:Send(...)
    local prefix, medium, msg = ...;
    if select("#", ...) == 2 then
        local channel = ...;
        medium, prefix = GetMediumAndPrefix(channel);
        msg = select(2, ...);
    end;
    assert(msg~=nil, "Message must not be nil");
    if type(msg) == "table" then
        for i=1, #msg do
            Remote:Send(prefix, medium, msg[i])
        end;
        return;
    end;
	--printf("medium=%s, prefix=%s", medium, prefix);
	if mediums[medium] then
		if ChatThrottleLib then
			ChatThrottleLib:SendAddonMessage("NORMAL", prefix, msg, mediums[medium]);
		else
			C_ChatInfo.SendAddonMessage(prefix, msg, mediums[medium]);
		end;
	else
		if ChatThrottleLib then
			ChatThrottleLib:SendAddonMessage("NORMAL", prefix, msg, "WHISPER", medium);
		else
			C_ChatInfo.SendAddonMessage(prefix, msg, "WHISPER", medium);
		end;
	end;
end;

function Remote:Install(channel)
    local _, prefix = GetMediumAndPrefix(channel);
    C_ChatInfo.RegisterAddonMessagePrefix(prefix);
    return Events.CHAT_MSG_ADDON(function(msgPrefix, message, medium, source)
        if prefix~=msgPrefix then
            return;
        end;
        Remote:Dispatch(GetChannel(medium, prefix), message, source);
        Remote:Dispatch(prefix, message, source);
    end);
end;

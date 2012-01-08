if nil ~= require then
	require "fritomod/currying";
	require "fritomod/Events";
	require "fritomod/Callbacks";
	require "fritomod/Functions";
	require "fritomod/Chat";
end;

Callbacks = Callbacks or {};

local CHANNEL_TYPE_OTHER = 0;
local CHANNEL_TYPE_GENERAL = 1;
local CHANNEL_TYPE_TRADE = 2;
local CHANNEL_TYPE_LOCALDEFENSE = 22;
local CHANNEL_TYPE_WORLDDEFENSE = 23;
local CHANNEL_TYPE_LFG = 26;

function Callbacks.ChannelJoinOrLeave(name, func, ...)
	if type(name) == "string" then
		name = name:lower();
	end;
	func = Curry(func, ...);
	return Events.CHAT_MSG_CHANNEL_NOTICE(function(status, ...)
		-- This is the 8th, not 9th, argument since we define status.
		local channelType = select(6, ...);
		if channelType == CHANNEL_TYPE_TRADE then
			trace("Got channel notice event for trade chat");
			if name ~= "trade" and not name:match("^trade%s+") then
				return;
			end;
		elseif channelType == CHANNEL_TYPE_GENERAL then
			trace("Got channel notice event for general chat");
			if name ~= "general" and not name:match("^general%s+") then
				return;
			end;
		elseif channelType == CHANNEL_TYPE_LOCALDEFENSE then
			trace("Got channel notice event for local defense");
			if name ~= "localdefense" and name ~= "local defense" and not name:match("^local ?defense%s+") then
				return;
			end;
		elseif channelType == CHANNEL_TYPE_WORLDDEFENSE then
			trace("Got channel notice event for world defense");
			if name ~= "worlddefense" and name ~= "world defense" and not name:match("^world ?defense%s+") then
				return;
			end;
		elseif channelType == CHANNEL_TYPE_LOOKINGFORGROUP then
			trace("Got channel notice event for looking for group")
			if name ~= "lookingforgroup" and
				name ~= "looking for group" and
				name ~= "lfg" and
				not name:match("^looking ?for ?group%s+") and
				not name:match("^lfg%s+") then
				return;
			end;
		else
			local channelName = select(8, ...);
			trace("Got channel notice event for channel: %q", channelName);
			channelName = channelName:lower();
			if name ~= channelName then
				return;
			end;
		end;
		local channelName = select(8, ...);
		if status == "YOU_JOINED" then
			trace("Emitting join event for %q", channelName);
			func(true);
		elseif status == "YOU_LEFT" or status == "SUSPENDED" then
			trace("Emitting leave event for %q", channelName);
			func(false);
		end;
	end);
end;

function Callbacks.JoinChannel(name, func, ...)
	func = Curry(func, ...);
	local onLeave;
	return Callbacks.ChannelJoinOrLeave(name, function(isJoin)
		if isJoin and not onLeave then
			onLeave = func();
		elseif onLeave then
			onLeave();
			onLeave = nil;
		end;
	end);
end;
Callbacks.JoinedChannel = Callbacks.JoinChannel;
Callbacks.ChannelJoined = Callbacks.JoinChannel;
Callbacks.ChannelJoin = Callbacks.JoinChannel;

function Callbacks.ImmediateJoinChannel(name, func, ...)
	if type(name) == "string" then
		name = name:lower();
	end;
	func = Curry(func, ...);
	local onLeave;
	if Chat.InChannel(name) then
		onLeave = func();
	end;
	return Callbacks.ChannelJoinOrLeave(name, function(isJoin)
		if isJoin and not onLeave then
			onLeave = func();
		elseif onLeave then
			onLeave();
			onLeave=nil;
		end;
	end);
end;
Callbacks.ImmediateJoinedChannel = Callbacks.ImmediateJoinChannel;
Callbacks.ImmediateChannelJoined = Callbacks.ImmediateJoinChannel;
Callbacks.ImmediateChannelJoin = Callbacks.ImmediateJoinChannel;

function Callbacks.LeftChannel(name, func, ...)
	return Callbacks.JoinChannel(name, Functions.ReverseUndoable(func, ...))
end;
Callbacks.LeaveChannel = Callbacks.LeftChannel;
Callbacks.LeavingChannel = Callbacks.LeftChannel;
Callbacks.ChannelLeft = Callbacks.LeftChannel;

function Callbacks.ImmediateLeftChannel(name, func, ...)
	if type(name) == "string" then
		name = name:lower();
	end;
	func = Curry(func, ...);
	local onJoin;
	if not Chat.InChannel(name) then
		onJoin = func();
	end;
	return Callbacks.ChannelJoinOrLeave(name, function(isJoin)
		if isJoin and onJoin then
			-- We're joining, so fire our remover.
			onJoin();
			onJoin=nil;
		elseif not onJoin then
			-- We're leaving, so fire our listener as long as we haven't
			-- fired it before.
			onJoin = func();
		end;
	end);
end;
Callbacks.ImmediateLeaveChannel = Callbacks.ImmediateLeftChannel;
Callbacks.ImmediateLeavingChannel = Callbacks.ImmediateLeftChannel;
Callbacks.ImmediateChannelLeft = Callbacks.ImmediateLeftChannel;

local function ChannelJoinCallback(name)
	local joiner = Curry(Callbacks.JoinChannel, name);
	Callbacks["Join"..name] = joiner;
	Callbacks["Joined"..name] = joiner;
	Callbacks[name.."Join"] = joiner;
	Callbacks[name.."Joined"] = joiner;

	local immediateJoiner = Curry(Callbacks.ImmediateJoinChannel, name);
	Callbacks["ImmediateJoin"..name] = immediateJoiner;
	Callbacks["ImmediateJoined"..name] = immediateJoiner;
	Callbacks["Immeidate"..name.."Join"] = immediateJoiner;
	Callbacks["Immediate"..name.."Joined"] = immediateJoiner;

	local leaver = Callbacks.ReverseCallback("Join"..name);
	Callbacks["Leave"..name] = leaver;
	Callbacks["Left"..name] = leaver;
	Callbacks[name.."Left"] = leaver;

	local immediateLeaver = Curry(Callbacks.ImmediateLeaveChannel, name);
	Callbacks["ImmediateLeft"..name] = immediateLeaver;
	Callbacks["ImmediateLeave"..name] = immediateLeaver;
	Callbacks["Immeidate"..name.."Left"] = immediateLeaver;
end;

ChannelJoinCallback("Trade");
ChannelJoinCallback("General");
ChannelJoinCallback("LookingForGroup");
Callbacks.JoinLFG = Callbacks.JoinLookingForGroup;
Callbacks.JoinedLFG = Callbacks.JoinLFG;
Callbacks.LFGJoin = Callbacks.JoinLFG;
Callbacks.LFGJoined = Callbacks.JoinLFG;

Callbacks.LeftLFG = Callbacks.LeftLookingForGroup;
Callbacks.LeaveLFG = Callbacks.LeftLFG;
Callbacks.LFGLeft = Callbacks.LeftLFG;

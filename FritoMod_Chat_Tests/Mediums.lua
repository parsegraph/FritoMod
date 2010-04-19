if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_Chat/Mediums";
end;

local Suite = ReflectiveTestSuite:New("FritoMod_Chat.Mediums");

Suite:AddListener(Metatables.Noop({
	TestStarted = function(self, suite)
		suite.messages = {};
		self.oldGetDefaultLanguage = GetDefaultLanguage;
		GetDefaultLanguage = function()
			return "Common";
		end;
		self.oldSendChatMessage = SendChatMessage;
		SendChatMessage = function(...) -- msg, chatType, language, channel
			local s = select("#", ...);
			-- These tests ensure information is not lost when we store the arguments.
			if s >= 2 then
				assert(select(1, ...) ~= nil, "msg must not be nil if chatType is provided");
			end;
			if s >= 3 then
				assert(select(2, ...) ~= nil, "chatType must not be nil if language is provided");
			end;
			if s >= 4 then
				assert(select(3, ...) ~= nil, "language must not be nil if channel is provided");
			end;
			table.insert(suite.messages, {...});
		end;
		self.oldGetChannelName = GetChannelName;
		GetChannelName = function(name)
			local channels = {
				"general",
				"localdefense",
				"notime"
			};
			local proper = {
				"General - Dun Morogh",
				"LocalDefense",
				"Notime"
			};
			if type(name) == "string" then
				name = name:lower();
				local id = Lists.KeyFor(channels, name);
				if id ~= nil then
					return id, proper[id], 0;
				end;
			elseif proper[name] then
				return name, proper[name], 0;
			end;
			return 0, nil, 0;
		end;
	end,
	TestFinished = function(self, suite)
		SendChatMessage = self.oldSendChatMessage;
		GetChannelName = self.oldGetChannelName;
		GetDefaultLanguage = self.oldGetDefaultLanguage;
	end
}));

function Suite:TestMediumsSay()
	Mediums.Say("test");
	Assert.Equals({"test", "SAY"}, table.remove(self.messages));
end;

function Suite:TestMediumsChannel()
	Mediums.General("Hello, general!");
	Assert.Equals({"Hello, general!", "CHANNEL", "Common", 1}, table.remove(self.messages));
end;

function Suite:TestWhisper()
	Mediums.Threep("Hello, Threep!");
	Assert.Equals({"Hello, Threep!", "WHISPER", "Common", "threep"}, table.remove(self.messages));
end;

function Suite:TestMediumsAlias()
	Mediums.g("Hello, guild!");
	Assert.Equals({"Hello, guild!", "GUILD"}, table.remove(self.messages));
end;

function Suite:TestMediumsWhisper()
	Mediums.w("Threep", "Hello, Threep!");
	Assert.Equals({"Hello, Threep!", "WHISPER", "Common", "threep"}, table.remove(self.messages));
end;

function Suite:TestMediumsBatchDispatch()
	local s = "Hello, guild and party!";
	Mediums[{"g","p"}](s);
	Assert.Equals({s, "PARTY"}, table.remove(self.messages));
	Assert.Equals({s, "GUILD"}, table.remove(self.messages));
end;

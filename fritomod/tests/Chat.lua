local Suite = CreateTestSuite("Chat");

Suite:AddListener(Metatables.Noop({
	TestStarted = function(self, suite)
		suite.messages = {};
		self.oldSend=Chat.__Send;
        Chat.__Send=function(message, medium, language, target)
            assert(message~=nil, "Message must not be nil");
            assert(medium~=nil, "Medium must not be nil");
            assert(language~=nil, "Language must not be nil");
            assert(target~=nil, "Target must not be nil");
			table.insert(suite.messages, {message, medium, language, target});
		end;
		self.oldChannelName = Chat.__ChannelName;
		Chat.__ChannelName = function(name)
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
        Chat.__Send = self.oldSend;
        Chat.__ChannelName = self.oldChannelName;
	end
}));

function Suite:TestChatSay()
	Chat.Say("test");
	Assert.Equals({"test", "SAY", Chat.__Language(), ""}, table.remove(self.messages));
end;

function Suite:TestChatChannel()
	Chat.General("Hello, general!");
	Assert.Equals({"Hello, general!", "CHANNEL", Chat.__Language(), 1}, table.remove(self.messages));
end;

function Suite:TestWhisper()
	Chat.Threep("Hello, Threep!");
	Assert.Equals({"Hello, Threep!", "WHISPER", Chat.__Language(), "threep"}, table.remove(self.messages));
end;

function Suite:TestChatAlias()
	Chat.g("Hello, guild!");
	Assert.Equals({"Hello, guild!", "GUILD", Chat.__Language(), ""}, table.remove(self.messages));
end;

function Suite:TestChatWhisper()
	Chat.w("Threep", "Hello, Threep!");
	Assert.Equals({"Hello, Threep!", "WHISPER", Chat.__Language(), "threep"}, table.remove(self.messages));
end;

function Suite:TestChatBatchDispatch()
	local s = "Hello, guild and party!";
	Chat[{"g","p"}](s);
	Assert.Equals({s, "PARTY", Chat.__Language(), ""}, table.remove(self.messages));
	Assert.Equals({s, "GUILD", Chat.__Language(), ""}, table.remove(self.messages));
end;

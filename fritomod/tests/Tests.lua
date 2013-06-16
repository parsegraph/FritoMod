local Suite = CreateTestSuite("fritomod.Tests");

function Suite:TestSimpleFlagMechanics()
	local flag = Tests.Flag();
	assert(not flag.IsSet(), "Flag starts unset");
	flag.Raise();
	assert(flag.IsSet(), "Flag raises");
end;

function Suite:TestFlagCanBeSetOnConstruction()
	local flag = Tests.Flag(true);
	assert(flag.IsSet(), "Flag can be set to raised");
end;

function Suite:TestCounterCanBeSetOnConstruction()
	local counter = Tests.Counter(2);
	Assert.Equals(2, counter.Get(), "Counter accepts an optional initial value");
	Assert.Exception("Counter rejects non-numeric initial values", Tests.Counter, true);
end;

function Suite:TestFlagIgnoresSpuriousRaiseCalls()
	local flag = Tests.Flag();
	flag.Raise();
	assert(flag.IsSet(), "Flag raises");
	flag.Raise();
	assert(flag.IsSet(), "Flag remains raised");
end;

function Suite:TestFlagClears()
	local flag = Tests.Flag();
	flag.Raise();
	assert(flag.IsSet(), "Flag raises");
	flag.Clear();
	assert(not flag.IsSet(), "Flag clears");
end;

function Suite:TestFlagClearsWithMethodCalls()
	local flag = Tests.Flag();
	flag:Raise();
	assert(flag:IsSet(), "Flag raises");
	flag:Clear();
	assert(not flag:IsSet(), "Flag clears");
end;

function Suite:TestFlagAsserts()
	local flag = Tests.Flag();
	flag.Raise();
	assert(flag.IsSet(), "Flag raises");
	flag.Assert();
end;

function Suite:TestFlagAssertUnset()
	local flag = Tests.Flag();
	Assert.Succeeds("Flag asserts unset on initial state", flag.AssertUnset);
	flag.Raise();
	Assert.Exception("Flag fails unset-assertion when flag is raised", flag.AssertUnset);
end;

function Suite:TestFlagAssertCanFail()
	local flag = Tests.Flag();
	assert(not pcall(flag.Assert), "Assert fails on unset flag");
end;

function Suite:TestSimpleCounter()
	local counter = Tests.Counter();
	Assert.Equals(0, counter:Get(), "Counter starts at zero");
	counter:Hit();
	Assert.Equals(1, counter:Get(), "Counter increments to one");
end;

function Suite:TestCounterAsserts()
	local counter = Tests.Counter();
	Assert.Equals(0, counter:Get(), "Counter starts at zero");
	counter:Hit();
	counter:Assert(1, "Counter asserts that it's at one");
end;

function Suite:TestCounterResetsToInitialValue()
	local c = Tests.Counter(42);
	c.Assert(42);
	c.Reset();
	c.Assert(42);
end;

function Suite:TestCounterAssertsCorrectly()
	local c = Tests.Counter(0);
	c.Assert(0);
	c.Hit();
	c.Assert(1);
	Assert.Exception("Counter fails on bad number", c.Assert, 42);
end;

function Suite:TestDebugStackHandlesHeadProperly()
	if not debug then
		return;
	end;
	local h,t=Tests.PartialStackTrace(1,2,0);
	Assert.Size(2, h, "Head contains two elements");
	Assert.Size(0, t, "Tail is empty");
	local s=Tests.FullStackTrace(0,100,0);
	local h,t=Tests.PartialStackTrace(0,100,0);
	Assert.Size(s, h, "Head contains equal number of elements as full stack trace");
	Assert.Nil(t, "Tail is not defined");
end;

function Suite:TestFullStackTrace()
	if not debug then
		return;
	end;
	local stackTrace = Tests.FullStackTrace();
	assert(stackTrace[1].name:match("FullStackTrace"),
		"First stack level is FullStackTrace. Level was: " .. Strings.Pretty(stackTrace[1].name));
end;

local TEST_FILE=[[.*tests[/\]Tests[.]lua]];

function Suite:TestPartialStackTrace()
	if not debug then
		return;
	end;
	local stackTrace = Tests.PartialStackTrace();
	assert(stackTrace[1].name:match(TEST_FILE),
		"First stack level is the site of the stack-trace call. Level was: " .. stackTrace[1].name);
end;

function Suite:TestDebugStackWithoutCallingBuiltInFunction()
	if debug and debugstack then
		local strace=debugstack();
		local D=debugstack;
		debugstack=nil;
		local r,v=pcall(Tests.FormattedPartialStackTrace);
		debugstack=D;
		assert(r, v);
		local pcallFirst,v=unpack(Strings.SplitByDelimiter("\n", v,2));
		assert(pcallFirst:find("pcall"), "First line refers to the pcall");
		local debugstackLevels=Strings.SplitByDelimiter("\n", strace);
		local createdLevels=Strings.SplitByDelimiter("\n", v);
		for i=1, #debugstackLevels do
			assert(#createdLevels >= i, "Created levels must have same number of levels as debugstack");
			if i==1 then
				local l1=debugstackLevels[i]:gsub("[0-9]+","###");
				local l2=createdLevels[i]:gsub("[0-9]+","###");
				Assert.Equals(l1,l2, "First stack levels are equal, ignoring numbers");
			else
				Assert.Equals(debugstackLevels[i], createdLevels[i], "Stack level must be identical. Level: " .. i);
			end;
		end;
		Assert.Size(debugstackLevels,createdLevels,"Created levels must have same number of levels as debugstack");
	end;
end;

function Suite:TestFormattedPartialStackTraceIsEqualToDebugStack()
	if not debugstack then
		return;
	end;
	local dstack=Strings.SplitByDelimiter("\n", debugstack());
	local strace=Strings.SplitByDelimiter("\n", Tests.FormattedPartialStackTrace());
	for i=1, #dstack do
		assert(#strace >= i, "Created levels must have same number of levels as debugstack");
		if i==1 then
			local l1=dstack[i]:gsub("[0-9]+","###");
			local l2=strace[i]:gsub("[0-9]+","###");
			Assert.Equals(l1,l2, "First stack levels are equal, ignoring numbers");
		else
			Assert.Equals(dstack[i], strace[i], "Stack level must be identical. Level: " .. i);
		end;
	end;
	Assert.Size(#dstack,strace,"Created levels must have same number of levels as debugstack");
end;

function Suite:TestDebugStack()
	if not debugstack then
		return;
	end;
	local l=unpack(Strings.SplitByDelimiter("\n", debugstack(),2));
	assert(l:match(TEST_FILE), "debugstack's first level is the test case: " .. l);
end;

function Suite:TestFormattedPartialStackTrace()
	local stackTrace = Tests.FormattedPartialStackTrace();
	local firstLine, _ = unpack(Strings.SplitByDelimiter("\n", stackTrace, 2));
	assert(firstLine:match(TEST_FILE),
		"First line of default stack trace refers to the site of the stack-trace call. Line was: " ..
		Strings.Pretty(firstLine));
end;

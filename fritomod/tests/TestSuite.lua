if nil ~= require then
	require "fritomod/Strings";
end;

local Suite = CreateTestSuite("fritomod.TestSuite");

function Suite:TestErrorStackTraceOutputsProperly()
	local suite = TestSuite:New();
	function suite:GetTests()
		return {
			function()
				error("Intentional error");
			end;
		};
	end;
    local flag = Tests.Flag();
	suite:AddListener(Metatables.Noop({
		TestFailed = function(self, suite, testName, testRunner, reason)
            flag.Raise();
			local reason, trace = unpack(Strings.SplitByDelimiter("\n", reason));
            assert(reason:match("Intentional error$"), reason);
		end,
	}));
	suite:Run();
    flag.Assert();
end;

function Suite:TestAssertStackTraceOutputsProperly()
	local suite = TestSuite:New();
	function suite:GetTests()
		return {
			function()
				assert(false, "Intentional false assertion");
			end;
		};
	end;
    local flag = Tests.Flag();
	suite:AddListener(Metatables.Noop({
		TestFailed = function(self, suite, testName, testRunner, reason)
            flag.Raise();
			local reason, trace = unpack(Strings.SplitByDelimiter("\n", reason));
            assert(reason:match("Intentional false assertion$"), reason);
		end,
	}));
	suite:Run();
    flag.Assert();
end;

function Suite:TestCrashStackTraceOutputsProperly()
	local suite = TestSuite:New();
	function suite:GetTests()
		return {
			function()
				local foo = {};
				foo = nil;
				-- Intentional crash
				foo.bar = 42;
			end;
		};
	end;
    local flag = Tests.Flag();
	suite:AddListener(Metatables.Noop({
		TestFailed = function(self, suite, testName, testRunner, reason)
            flag.Raise();
			assert(reason:match(".*tests[/\\]TestSuite\.lua:[0-9]+: attempt to"),
				"Reason contains stack trace");
		end
	}));
	suite:Run();
    flag.Assert();
end;

function Suite:TestThatTestSuiteErrorsWhenNotOverridden()
	local suite = TestSuite:New();
	Assert.Exception("Suite requires GetTests to be overridden", suite.Run, suite);
end;

function Suite:TestListenersDuringSuccess()
	local suite = TestSuite:New();
	function suite:GetTests()
		return {Noop};
	end;
	local order = {};
	suite:AddListener(Metatables.FocusedTable({}, function(self, eventName, ...)
		Lists.Insert(order, eventName);
	end));
	local expected = {
		"StartAllTests",
		"TestStarted",
		"TestSuccessful",
		"TestFinished",
		"FinishAllTests"
	};
	suite:Run();
	Assert.Equals(expected, order, "One successful test emits proper events");
end;

function Suite:TestListenersDuringFailure()
	local suite = TestSuite:New();
	function suite:GetTests()
		return {Operator.False};
	end;
	local order = {};
	suite:AddListener(Metatables.FocusedTable({}, function(self, eventName, ...)
		Lists.Insert(order, eventName);
	end));
	local expected = {
		"StartAllTests",
		"TestStarted",
		"TestFailed",
		"TestFinished",
		"FinishAllTests"
	};
	suite:Run();
	Assert.Equals(expected, order, "One failed test emits proper events");
end;

function Suite:TestThatTestSuiteIgnoresReturnedArguments()
	local suite = TestSuite:New();
	function suite:GetTests()
		return {
			function()
				return true;
			end,
			function()
				return nil;
			end,
			function()
				return 0
			end
		};
	end;
	assert(false ~= suite:Run(), "Suite ignores returned arguments except false");
end;

function Suite:TestThatTestSuiteFailsOnFalse()
	local suite = TestSuite:New();
	function suite:GetTests()
		return {
			function()
				return false;
			end,
		};
	end;
	Assert.Equals(false, suite:Run(), "Suite fails on false elements");
end;

function Suite:TestThatTestSuiteDefaultsToSucceeding()
	local suite = TestSuite:New();
	function suite:GetTests()
		return {};
	end;
	assert(false ~= suite:Run(), "Suite defaults to success");
end;

function Suite:TestThatTestSuiteHandlesChildTests()
	local suite = TestSuite:New();

	function suite:GetTests()
		local child = TestSuite:New();
		function child:GetTests()
			return {
				function()
					assert(true);
				end
			};
		end;
		return { child };
	end;
	assert(suite:Run());
end;

function Suite:TestThatTestSuiteEmitsFailureOnAssertion()
	local suite = TestSuite:New();
	function suite:GetTests()
		return {
			function()
				return false;
			end,
		};
	end;
	local flag = Tests.Flag();
	suite:AddRecursiveListener(Metatables.Noop({
		TestFailed = flag.Raise
	}));
	suite:Run();
    flag.Assert();
end;

-- This is: a script that runs a test runner. It currently is very much unsupported and actually
-- requires some code that's not in FritoMod proper.

function TestingSlashCommand()
    local testNameColor = "00BFFF";
    local passedResultColor = "00FF00";
    local failedResultColor = "FF0000";

    local function Print(text, ...)
        DEFAULT_CHAT_FRAME:AddMessage(format(text, ...), 0x00, 0xCC, 0xCC);
    end;

    local function TestName(testIndex, name)
        return format("Test %d (|cff%s%s|r)", testIndex, testNameColor, name);
    end;

    local function ColorResult(successful)
        if successful then
            return format("|cff%sPassed|r", passedResultColor);
        end;
        return format("|cff%sFailed|r", failedResultColor);
    end;

    local tests, numRan;
    local removers = {
        AllTests:AddListener(Metatables.Noop({
            StartAllTests = function(self)
                tests = {};
                numRan = 0;
            end,
                    
            FinishAllTests = function(self, suite, successful)
                Print("%d tests ran. Result: %s", numRan, ColorResult(successful));
            end
        })),

        AllTests:AddRecursiveListener(Metatables.Noop({
            TestStarted = function(self, suite, name, runner)
                numRan = numRan + 1;
            end,
            TestFailed = function(self, suite, name, runner, reason)
                Print("%s failed with ssertion: %s" , TestName(#tests + 1, name), reason);
                Lists.Insert(tests, runner);
            end,
            TestErrored = function(self, suite, name, runner, errorMessage)
                Print("%s crashed with error: %s" , TestName(#tests + 1, name), errorMessage);
                Lists.Insert(tests, runner);
            end,
        }))
    };

    RegisterSlash(function(cmd)
        if not cmd or cmd == "" then
            AllTests:Run();
            return;
        end;
        if tonumber(cmd) then
            local index = tonumber(cmd);
            local test = tests[index];
            if not test then
                Print("Test not found: '%s'", cmd);
                return;
            end;
            test();
        else
            AllTests:Run(cmd);
        end;
    end, "test");

    return Curry(Lists.CallEach, removers);
end;

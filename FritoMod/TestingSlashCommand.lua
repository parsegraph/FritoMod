-- This is: a script that runs a test runner. It currently is very much unsupported and actually
-- requires some code that's not in FritoMod proper.

function TestingSlashCommand()
    local testNameColor = "FFE5B4";
    local passedResultColor = "00FF00";
    local failedResultColor = "FF0000";

    local infoColor = 0xc9c0bb;

    local errorColor = 0xE34234;
    local testCrashedColor = "E34234";
    local crashedReasonColor = "FA8072"; 

    local failureColor = 0xe1a95f;
    local testFailedColor = "EF9B0F";
    local failedReasonColor = "c2b280";

    local function DumpColor(color)
        local r = bit.rshift(bit.band(color, 0xFF0000), 16) / 0xFF;
        local g = bit.rshift(bit.band(color, 0x00FF00), 8) / 0xFF;
        local b = bit.band(color, 0x0000FF) / 0xFF;
        return r, g, b;
    end;

    local function PrintWithColor(text, r, g, b)
        DEFAULT_CHAT_FRAME:AddMessage(text, r, g, b);
    end;

    local function Print(text, ...)
        PrintWithColor(format(text, ...), DumpColor(infoColor));
    end;

    local function PrintFailure(text, ...)
        PrintWithColor(format(text, ...), DumpColor(failureColor));
    end;

    local function PrintError(text, ...)
        PrintWithColor(format(text, ...), DumpColor(errorColor));
    end;

    local function TestInfo(testIndex, name)
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
                local testIndex = #tests + 1;
                PrintFailure("[|cff%sFAIL|r] %d. %s\n|cff%s%s|r", testFailedColor, testIndex, name, failedReasonColor, reason);
                Lists.Insert(tests, runner);
            end,
            TestErrored = function(self, suite, name, runner, errorMessage)
                local testIndex = #tests + 1;
                PrintError("[|cff%sCRASH|r] %d. %s\n|cff%s%s|r", testCrashedColor, testIndex, name, crashedReasonColor, errorMessage);
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

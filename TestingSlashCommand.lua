if nil ~= require then
    require "currying";
    require "Lists";
    require "AllTests";
    require "Slash";
end;

function TestingSlashCommand()
    local testNameColor = "FFE5B4";
    local cumulativePassColor = 0x32CD32;
    local cumulativeFailedColor = 0xE52B50;

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
        PrintWithColor(text:format(...), DumpColor(infoColor));
    end;

    local function PrintFailure(text, ...)
        PrintWithColor(text:format(...), DumpColor(failureColor));
    end;

    local function PrintError(text, ...)
        PrintWithColor(text:format(...), DumpColor(errorColor));
    end;

    local function TestInfo(testIndex, name)
        return ("Test %d (|cff%s%s|r)"):format(testIndex, testNameColor, name);
    end;

    local tests, numRan, numSuccessful, numCrashed, numFailed;
    local removers = {
        AllTests:AddListener(Metatables.Noop({
            StartAllTests = function(self)
                tests = {};
                numRan = 0;
                numSuccessful = 0;
                numFailed = 0;
                numCrashed = 0;
            end,
                    
            FinishAllTests = function(self, suite, successful, report)
                if successful then
                    PrintWithColor(("Cumulative: All %d tests ran successfully."):format(numRan), DumpColor(cumulativePassColor));
                else
                    PrintWithColor(("Cumulative: %d of %d tests ran successfuly. %d failed, %d crashed"):format(
                        numSuccessful,
                        numRan,
                        numFailed,
                        numCrashed), DumpColor(cumulativeFailedColor));
                end;
            end
        })),

        AllTests:AddRecursiveListener(Metatables.Noop({
            TestStarted = function()
                numRan = numRan + 1;
            end,
            TestSuccessful = function(self, suite, name, runner, reason)
                numSuccessful = numSuccessful + 1;
            end,
            TestFailed = function(self, suite, name, runner, reason)
                numFailed = numFailed + 1;
                local testIndex = #tests + 1;
                PrintFailure("[|cff%sFAIL|r] %d. %s\n|cff%s%s|r", testFailedColor, testIndex, name, failedReasonColor, reason);
                Lists.Insert(tests, runner);
            end,
            TestCrashed = function(self, suite, name, runner, errorMessage)
                numCrashed = numCrashed + 1;
                local testIndex = #tests + 1;
                PrintError("[|cff%sCRASH|r] %d. %s\n|cff%s%s|r", testCrashedColor, testIndex, name, crashedReasonColor, errorMessage);
                Lists.Insert(tests, runner);
            end,
        }))
    };

    Slash.Register("test", function(cmd)
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
    end);

    return Curry(Lists.CallEach, removers);
end;

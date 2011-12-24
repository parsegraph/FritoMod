if nil ~= require then
    require "fritomod/currying";
    require "fritomod/Lists";
    require "fritomod/AllTests";
    require "fritomod/Slash";
    require "fritomod/Persistence";
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

    local runners;
    local report;
    local removers = {
        AllTests:AddListener(Metatables.Noop({
            StartAllTests = function(self)
                runners = {};
                report={
                    date=date(),
                    startTime=GetTime(),
                    tests={},
                    successes={},
                    failures={},
                    crashes={},
                    state="Running",
                    numRan=0
                };
                if Persistence:Loaded() then
                    local N="FritoMod.Cumulative Tests";
                    Persistence[N]=Persistence[N] or {};
                    table.insert(Persistence[N], report);
                end;
            end,

            FinishAllTests = function(self, suite, successful, reason)
                report.finishTime=GetTime();
                if successful then
                    report.state="Successful";
                    PrintWithColor(
                        ("Cumulative: All %d tests ran successfully."):format(report.numRan),
                        DumpColor(cumulativePassColor)
                    );
                else
                    report.state="Failed";
                    report.reason=reason;
                    PrintWithColor(("Cumulative: %d of %d tests ran successfuly. %d failed, %d crashed"):format(
                        #report.successes,
                        report.numRan,
                        #report.failures,
                        #report.crashes),
                        DumpColor(cumulativeFailedColor)
                    );
                end;
            end
        })),

        AllTests:AddRecursiveListener(Metatables.Noop({
            TestStarted = function(self, suite, name, runner)
                report.numRan=report.numRan+1;
                assert(not report.tests[name], "Duplicate test name: "..name);
                report.tests[name]={
                    index=#report.tests,
                    startTime=GetTime(),
                    state="Running"
                };
            end,
            TestSuccessful = function(self, suite, name, runner, reason)
                table.insert(report.successes, name);
            end,
            TestFailed = function(self, suite, name, runner, reason)
                table.insert(report.failures, name);
                local testIndex = #runners + 1;
                PrintFailure("[|cff%sFAIL|r] %d. %s\n|cff%s%s|r", testFailedColor, testIndex, name, failedReasonColor, reason);
                Lists.Insert(runners, runner);
            end,
            TestCrashed = function(self, suite, name, runner, errorMessage)
                table.insert(report.crashes, name);
                local testIndex = #runners + 1;
                PrintError("[|cff%sCRASH|r] %d. %s\n|cff%s%s|r", testCrashedColor, testIndex, name, crashedReasonColor, errorMessage);
                Lists.Insert(runners, runner);
            end,
            TestFinished=function(self, suite, name, runner, state, reason)
                local currentTest=report.tests[name];
                currentTest.finishTime=GetTime();
                currentTest.state=state;
                currentTest.reason=reason;
            end
        }))
    };

    Slash.Register("test", function(cmd)
        if not cmd or cmd == "" then
            AllTests:Run();
            return;
        end;
        if tonumber(cmd) then
            local index = tonumber(cmd);
            local test = runners[index];
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

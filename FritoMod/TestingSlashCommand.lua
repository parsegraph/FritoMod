-- This is: a script that runs a test runner. It currently is very much unsupported and actually
-- requires some code that's not in FritoMod proper.

function TestingSlashCommand()
    local baseColor = "75B2DD";
    local testNameColor = "00BFFF";
    local passedResultColor = "00FF00";
    local failedResultColor = "FF0000";
    
    local function TestName(testIndex, name)
        return format("|r|cff%s|rTest %d (|cff%s%s|r)", baseColor, testIndex, testNameColor, name);
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
                local result = ColorResult(successful);
                print(format("%d tests ran. Result: ", numRan)  ..  result);
            end
        })),

        AllTests:AddRecursiveListener(Metatables.Noop({
            TestStarted = function(self, suite, name, runner)
                numRan = numRan + 1;
            end,
            TestFailed = function(self, suite, name, runner, reason)
                print(format("%s failed with ssertion: %s" , TestName(#tests + 1, name), reason));
                Lists.Insert(tests, runner);
            end,
            TestErrored = function(self, suite, name, runner, errorMessage)
                print(format("%s crashed with error: %s" , TestName(#tests + 1, name), errorMessage));
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
                print("Test not found: '" .. cmd .. "'");
                return;
            end;
            test();
        else
            AllTests:Run(cmd);
        end;
    end, "test");

    return Curry(Lists.CallEach, removers);
end;

#!/usr/bin/lua
require "lfs"
require "FritoMod/global";

for i=1,#arg do
	dofile(arg[i]);
end;

do
    local tests, numRan, numSuccessful, numCrashed, numFailed;
    require("FritoMod_Testing/AllTests");

    AllTests:AddListener(Metatables.Noop({
        StartAllTests = function(self, suite, name, runner, reason)
            tests = {};
            numRan = 0;
            numSuccessful = 0;
            numFailed = 0;
            numCrashed = 0;
        end,
                    
        FinishAllTests = function(self, suite, successful, report)
            if successful then
                print(("Cumulative: All %d tests ran successfully."):format(numRan));
            else
                print(("Cumulative: %d of %d tests ran successfuly. %d failed, %d crashed"):format(
                    numSuccessful,
                    numRan,
                    numFailed,
                    numCrashed));
            end;
        end
    }));

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
            print(("[FAIL] %d. %s\n  %s"):format(testIndex, name, reason:gsub("\n", "\n    ")));
            Lists.Insert(tests, runner);
        end,

        TestCrashed = function(self, suite, name, runner, errorMessage)
            numCrashed = numCrashed + 1;
            local testIndex = #tests + 1;
            print(("[CRASH] %d. %s\n%s"):format(testIndex, name, errorMessage));
            Lists.Insert(tests, runner);
        end,

    }));
    AllTests:Run();
end;

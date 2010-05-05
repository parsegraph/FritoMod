#!/usr/bin/lua
require "lfs"
require "FritoMod/CreateTestSuite";
--require "FritoMod_Testing/AllTests";

if lfs.currentdir():find("FritoMod$") then
    lfs.chdir("..");
end;

local function ParseAddonToC(tocFileName, dirName)
    io.input(tocFileName);
    for line in io.lines() do
        if not line:find("^#") and line:find("\.lua$") then
            local filename = ("./%s/%s"):format(dirName, line);
            dofile(filename);
        end;
    end;
    io.input();
end;

for dirname in lfs.dir(".") do 
    local entry = lfs.attributes(dirname);
    if entry.mode == "directory" and dirname:find("Tests?$") then
        local tocFileName = ("./%s/%s.toc"):format(dirname, dirname);
        local tocFileEntry = lfs.attributes(tocFileName);
        if tocFileEntry and tocFileEntry.mode == "file" then
            ParseAddonToC(tocFileName, dirname);
        end;
    end;
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

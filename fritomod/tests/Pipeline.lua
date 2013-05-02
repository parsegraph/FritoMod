if nil ~= require then
    require "fritomod/Pipe";
end;

local Suite = CreateTestSuite("fritomod.Pipeline");

function Suite:TestDegeneratePipeline()
    local pipeline = Pipeline:New();

    local result = pipeline:Forward(42);
    Assert.Equals(42, result);

    pipeline:Add(Pipe.Noop());

    Assert.Equals(24, pipeline:Forward(24));
end;

function Suite:TestSpyPipeline()
    local pipeline = Pipeline:New();

    local forward = Tests.Value();
    local backward = Tests.Value();

    pipeline:Add(Pipe.Spy(function(isForward, value, update)
        if isForward then
            forward:Set(value);
        else
            backward.Set(value);
        end;
    end));

    pipeline:Forward(42);

    forward:Assert(42);
    backward:AssertUnset();

    local result = pipeline:Backward();

    backward:Assert(42);
end;

function Suite:TestSplitPipeline()
    local pipeline = Pipeline:New();

    pipeline:Add(Pipe.Split(" "));

    local result = pipeline:Forward("so little time");
    Assert.Equals({"so", "little", "time"}, result);

    local reversed = pipeline:Backward();
    Assert.Equals("so little time", reversed);
end;

function Suite:TestMapPipe()
    local pipeline = Pipeline:New();

    pipeline:Add(Pipe.Map(
        function(data)
            return {data = data};
        end,
        function(obj)
            return obj.data;
        end
    ));

    local result = pipeline:Forward({3, 4, 5});
    Assert.Equals(3, result[1].data);
    Assert.Equals(4, result[2].data);
    Assert.Equals(5, result[3].data);
end;

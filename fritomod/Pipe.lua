if nil ~= require then
    require "fritomod/Strings";
    require "fritomod/Lists";
    require "fritomod/currying";
end;

Pipe = Pipe or {};

function Pipe.Function(forward, backward)
    return function(value, pipeline)
        return forward(value, pipeline), backward;
    end;
end;

function Pipe.Flagged(func, ...)
    func = Curry(func, ...);
    return function(value, pipeline)
        return func(true, value, pipeline), Curry(func, false);
    end;
end;

function Pipe.Noop()
    return function(value, pipeline)
        return value, function(value)
            return value;
        end;
    end;
end;

function Pipe.Split(delimiter)
    return function(str, pipeline)
        return
            Strings.Split(delimiter, str),
            Curry(Strings.JoinArray, delimiter);
    end;
end;

function Pipe.Map(mapper, reverseMapper)
    return function(items, pipeline)
        return
            Lists.Map(items, mapper, pipeline),
            Headless(Lists.Map, reverseMapper);
    end;
end;

function Pipe.Pipeline(subPipeline)
    return function(value, pipeline)
        subPipeline:OnUpdate(pipeline, "Update");
        return
            pipeline:Forward(value),
            Curry(pipeline, "Backward");
    end;
end;

function Pipe.Spy(spy, ...)
    spy = Curry(spy, ...);
    return Pipe.Flagged(function(isForward, value)
        spy(isForward, value);
        return value;
    end);
end;

function Pipe.SpyForward(spy, ...)
    spy = Curry(spy, ...);
    return Pipe.Spy(function(isForward, value)
        if isForward then
            spy(value);
        end;
    end);
end;

function Pipe.SpyBackward(spy, ...)
    spy = Curry(spy, ...);
    return Pipe.Spy(function(isForward, value)
        if not isForward then
            spy(value);
        end;
    end);
end;

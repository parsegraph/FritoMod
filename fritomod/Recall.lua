if nil ~= require then
    require "fritomod/Persistence";
    require "fritomod/Frames";
    require "fritomod/Serializers-Point";
end;

Recall = Recall or {};

function Recall.Scratch(context)
    local mt = getmetatable(context) or {};
    setmetatable(context, mt);
    mt.__recall = mt.__recall or {};
    return mt.__recall;
end;

local function Generator()
    local id = 1;
    return function()
        local rv = id;
        id = id + 1;
        return rv;
    end;
end;

function Recall.Anonymous(context)
    local scratch = Recall.Scratch(context);
    if scratch.anonymous == nil then
        scratch.anonymous = Generator();
        Recall.OnReset(context, function()
            scratch.anonymous = nil;
        end);
    end;
    return scratch.anonymous();
end;

function Recall.GetEnvironment(context)
    return Recall.Scratch(context)._G;
end;

function Recall.SetEnvironment(context, env)
    Recall.Scratch(context)._G = env;
end;

function Recall.Reset(context)
    local scratch = Recall.Scratch(context);
    if scratch.resetters then
        Lists.CallEach(scratch.resetters);
        scratch.resetters = nil;
    end;
end;

function Recall.OnReset(context, func, ...)
    local scratch = Recall.Scratch(context);
    scratch.resetters = scratch.resetters or {};
    return Lists.InsertFunction(scratch.resetters, func, ...);
end;

function Recall.Position(context, frame, name)
    frame = Frames.AsRegion(frame);
    if not context.position then
        context.position = {};
    end;
    local scratch = Recall.Scratch(context.position);
    if not scratch.reset then
        Recall.OnReset(context, function()
            Recall.Reset(context.position);
            scratch.reset = nil;
        end);
        scratch.reset = true;
    end;
    name = name or Recall.Anonymous(context.position);
    local saved = context.position[name];
    if saved and #saved > 0 then
        Serializers.LoadAllPoints(saved, frame);
    else
        saved = nil;
    end;
    return saved ~= nil, function()
        context.position[name] = Serializers.SaveAllPoints(frame);
    end;
end;

function Recall.Value(context, target, name)
    local category = "value";
    if not context[category] then
        context[category] = {};
    end;
    local scratch = Recall.Scratch(context[category]);
    if not scratch.reset then
        Recall.OnReset(context, function()
            Recall.Reset(context[category]);
            scratch.reset = nil;
        end);
        scratch.reset = true;
    end;
    name = name or Recall.Anonymous(context[category]);
    local saved = context[category][name];
    target[name] = saved;
    return saved ~= nil, function()
        context[category][name] = target[name];
    end;
end;

function Recall.Global(context, name)
    return Recall.Value(context, Recall.GetEnvironment(context), name);
end;

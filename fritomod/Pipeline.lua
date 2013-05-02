if nil ~= require then
    require "fritomod/OOP-Class";
    require "fritomod/ListenerList";
end;

Pipeline = OOP.Class();

function Pipeline:Constructor()
    self.pipes = {};
    self.cleaners = {};
    self.reversals = {};
    self.listeners = ListenerList:New();
end;

function Pipeline:Add(pipe, ...)
    return Lists.InsertFunction(self.pipes, pipe, ...);
end;

function Pipeline:AddBackward(pipe, ...)
    return Lists.InsertFunction(self.reversals, pipe, ...);
end;

function Pipeline:AddCleaner(cleaner, ...)
    return Lists.InsertFunction(self.cleaners, cleaner, ...);
end;

function Pipeline:Forward(value)
    self:Reset();
    self.reversals = {};

    self.initial = value;
    self.result = value;
    for i, pipe in ipairs(self.pipes) do
        local reverse;
        local result, reverse = pipe(value, self);
        if result ~= nil then
            value = result;
        end;
        if reverse then
            table.insert(self.reversals, reverse);
        end;
        self.result = value;
    end;
    self:FireUpdate();
    return value;
end;

function Pipeline:Backward()
    if not self.reversals then
        return;
    end;
    local value = self.result;
    for i=#self.reversals, 1, -1 do
        value = self.reversals[i](value);
    end;
    return value;
end;

function Pipeline:Update()
    return self:Forward(self.initial);
end;

function Pipeline:Reset()
    if #self.cleaners == 0 then
        return;
    end;
    Lists.ReverseCallEach(self.cleaners);
    self.cleaners = {};
    self.initial = nil;
    self.result = nil;
end;

function Pipeline:OnUpdate(func, ...)
    return self.listeners:Add(func, ...);
end;

function Pipeline:FireUpdate()
    self.listeners:Fire(self.result);
end;

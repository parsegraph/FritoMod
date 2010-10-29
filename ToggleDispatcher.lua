if nil ~= require then
    require "currying";
    require "Functions";

    require "OOP-Class";
    require "Lists";
end;

ToggleDispatcher=OOP.Class();

function ToggleDispatcher:Constructor()
    self.listeners={};
    self.deadListeners={};
    self.resetters={};
end;

function ToggleDispatcher:Install()
    -- noop. Feel free to override this Undoable function.
end;

function ToggleDispatcher:Add(listener, ...)
    listener=Curry(listener, ...);
    if self.Install and #self.listeners - #self.deadListeners <= 0 then
        self.Uninstall=self:Install() or self.Uninstall;
    end;
    table.insert(self.listeners, listener);
    return Functions.OnlyOnce(function()
        table.insert(self.deadListeners, listener);
        if not self.iterating then
            self:CleanUp();
        end;
    end);
end;

function ToggleDispatcher:HasListeners()
    return #self.listeners > 0;
end;

function ToggleDispatcher:Fire(...)
    self.iterating=true;
    for _, listener in ipairs(self.listeners) do
        if not Lists.Contains(self.deadListeners, listener) then
            local resetter=listener(...);
            if resetter then
                table.insert(self.resetters, resetter);
                self.resetters[listener]=resetter;
                self.resetters[resetter]=listener;
            end;
        end;
    end;
    self.iterating=false;
    self:CleanUp();
end;

function ToggleDispatcher:CleanUp()
    assert(not self.iterating, "Cannot clean during iteration");
    for _, deadListener in ipairs(self.deadListeners) do
        Lists.Remove(self.listeners, deadListener);
        if self.resetters[deadListener] then
            local resetter=self.resetters[deadListener];
            Lists.Remove(self.resetters, resetter);
            self.resetters[deadListener]=nil;
            self.resetters[resetter]=nil;
        end;
    end;
    if #self.listeners == 0 and self.Uninstall then
        self:Uninstall();
    end;
end;

function ToggleDispatcher:Reset(...)
    if #self.resetters then
        for _, resetter in ipairs(self.resetters) do
            if self.resetters[resetter] then
                resetter(...);
            end;
        end;
        self.resetters={};
        self:CleanUp();
    end;
end;

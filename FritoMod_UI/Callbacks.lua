if nil ~= require then
    require "FritoMod_Functional/currying";
    require "FritoMod_Functional/Callbacks";
end;

local function ToggledEvent(onEvent, offEvent, installer, ...)
    if installer then
        installer=Curry(installer, ...);
    else
        installer=Noop;
    end;
    local eventListenerName=onEvent.."Listeners";
    return function(f, func, ...)
        func=Curry(func, ...);
        if f:GetScript(onEvent) then
            assert(f[eventListenerName],
            "Callbacks refuses to overwrite an existing listener");
        end;
        if not f[eventListenerName] then
            local listeners={
                onListeners={},
            };
            f[eventListenerName]=listeners;
            local uninstaller=installer(f) or Noop;
            local function CheckForDeath()
                if listeners.deadListeners and #listeners.deadListeners > 0 then
                    for _,deadListener in ipairs(listeners.deadListeners) do
                        Lists.Remove(listeners.onListeners, deadListener);
                        if listeners.offListeners then
                            for k,v in pairs(listeners.offListeners) do
                                if type(k)=="function" and v==deadListener then
                                    listeners.offListeners[k]=false;
                                end;
                            end;
                        end;
                    end;
                    listeners.deadListeners=nil;
                end;
                if #f.mouseEnters == 0 then
                    f:SetScript(onEvent, nil);
                    f:SetScript(offEvent, nil);
                    uninstaller(f);
                    f[eventListenerName]=nil;
                    return true;
                end;
                return false;
            end;
            f:SetScript(onEvent, function()
                    if CheckForDeath() then
                        return;
                    end;
                    local cloned=Lists.Clone(listeners.onListeners);
                    for _,onListener in ipairs(cloned) do
                        local offListener=onListener();
                        if offListener ~= nil then
                            listeners.offListeners=listeners.offListeners or {};
                            listeners.offListeners[offListener]=onListener;
                            table.insert(listeners.offListeners, offListener);
                        end;
                    end;
                    CheckForDeath();
            end);
            f:SetScript(offEvent, function()
                    if CheckForDeath() then
                        return;
                    end;
                    if listeners.offListeners then
                        for _, offListener in ipairs(listeners.offListeners) do
                            if listeners.offListeners[offListener] then
                                offListener();
                            end;
                        end;
                        CheckForDeath();
                    end;
            end);
        end;
        local listeners=f[eventListenerName];
        table.insert(listeners.onListeners, func);
        return Functions.OnlyOnce(function()
                listeners.deadListeners=listeners.deadListeners or {};
                table.insert(listeners.deadListeners, func);
        end);
    end;
end;

local function enableMouse()
    f:EnableMouse(true);
    return Seal(f, "EnableMouse", false);
end;

Callbacks.MouseDown=ToggledEvent("OnMouseDown", "OnMouseUp", enableMouse);
Callbacks.EnterFrame=ToggledEvent("OnEnter", "OnLeave", enableMouse);
Callbacks.ShowFrame=ToggledEvent("OnShow", "OnHide");

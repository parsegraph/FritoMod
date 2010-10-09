if nil ~= require then
    require "FritoMod_Functional/currying";
    require "FritoMod_Functional/Callbacks";
end;

local function ToggledEvent(onEvent, offEvent, installer)
    local uninstaller;
    local eventListenerName=onEvent.."Listeners";
    return function(frame, func, ...)
        func=Curry(func, ...);
        if frame:GetScript(onEvent) then
            assert(frame[eventListenerName],
            "Callbacks refuses to overwrite an existing "..onEvent.." listener");
        end;
        local dispatcher;
        if frame[eventListenerName] then
            dispatcher=frame[eventListenerName];
        else
            dispatcher=ToggleDispatcher:New();
            function dispatcher:Install()
                frame:SetScript(onEvent, Curry(dispatcher, "Fire"));
                frame:SetScript(offEvent, Curry(dispatcher, "Reset"));
                frame[eventListenerName]=dispatcher;
                if installer then
                    uninstaller=installer;
                end;
            end;
            function dispatcher:Uninstall()
                if uninstaller then
                    uninstaller();
                    uninstaller=nil
                end;
                frame:SetScript(onEvent, nil);
                frame:SetScript(offEvent, nil);
                frame[eventListenerName]=nil;
            end;
        end;
        return dispatcher:Add(func);
    end;
end;

local function enableMouse(f)
    f.mouseListenerTypes=f.mouseListenerTypes or 0;
    f.mouseListenerTypes=f.mouseListenerTypes+1;
    f:EnableMouse(true);
    return Functions.OnlyOnce(function()
        f.mouseListenerTypes=f.mouseListenerTypes-1;
        if f.mouseListenerTypes <= 0 then
            f:EnableMouse(false);
        end;
    end)
end;

Callbacks.DragFrame=ToggledEvent("OnDragStart", "OnDragStop", enableMouse);
Callbacks.MouseDown=ToggledEvent("OnMouseDown", "OnMouseUp", enableMouse);
Callbacks.EnterFrame=ToggledEvent("OnEnter", "OnLeave", enableMouse);
Callbacks.ShowFrame=ToggledEvent("OnShow", "OnHide");

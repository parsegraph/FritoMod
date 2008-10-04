API.Frame = OOP.Class(EventDispatcher);
local Frame = API.Frame;

Frame.__AddInitializer(function(class)
    class.REVERSE_WIDGET_HANDLERS = {
        OnEnter = "FOCUS_ENTER", 
        OnLeave = "FOCUS_LEAVE",
        OnLoad = "LOAD",
        OnSizeChanged = "SIZE_CHANGE",
        OnUpdate = "UPDATE",

        OnShow = "VISIBLE_SHOW",
        OnHide = "VISIBLE_HIDE",

        OnKeyDown = "KEY_DOWN",
        OnKeyUp = "KEY_UP",
        OnChar = "KEY_CHAR",

        OnClick = "MOUSE_CLICK", 
        OnDoubleClick = "MOUSE_CLICK_DOUBLE",
        OnMouseDown = "MOUSE_DOWN",
        OnMouseUp = "MOUSE_UP",
        OnMouseWheel = "MOUSE_WHEEL",

        OnDragStart = "MOUSE_DRAG_START",
        OnDragStop = "MOUSE_DRAG_STOP",
        OnReceiveDrag = "MOUSE_DRAG_DROP",
    };
    class.WIDGET_HANDLERS = {};
    for widgetEventName, handlerName in pairs(class.REVERSE_WIDGET_HANDLERS) do
        class.WIDGET_HANDLERS[handlerName] = widgetEventName;
    end;
end);

Frame.frameTypes = {
    FRAME = "frame"
};

Frame.SetStaticEventInitializer(true, function(self, eventName)
    local widgetEventName = Frame.WIDGET_HANDLERS[eventName];
    if not widgetEventName then
        return;
    end;
    self.frame:SetScript(widgetEventName, function(...)
        self:DispatchEvent(eventName, ...);
    end);
    return function()
        self:GetFrame():SetScript(widgetEventName, nil);
    end;
end);

function Frame:__Init(frameType, inheritedFrames)
    frameType = frameType or Frame.frameTypes.FRAME;
    frameType = string.lower(frameType);
    if not LookupValue(Frame.frameTypes, frameType) then
        error("Unrecognized frameType: " .. frameType);
    end;
    self.type = frameType;
    if type(inheritedFrames) == "string" then
        self.inheritedFrames = { string.split(",", inheritedFrames) };
    else
        self.inheritedFrames = inheritedFrames or {};
    end;
    self.rawFrame = CreateFrame(self.type, nil, nil, string.join(",", self.inheritedFrames));
    self:GetFrame():SetScript("OnEvent", function(rawFrame, eventName, ...)
        self:DispatchEvent(eventName, ...);
    end);
end;

function Frame:GetFrame()
    return self.rawFrame;
end;

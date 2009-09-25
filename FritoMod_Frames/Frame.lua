Frame = OOP.Class();
local Frame = Frame;

Frame.events = {
    FOCUS_ENTER = "OnEnter",
    FOCUS_LEAVE = "OnLeave",
    LOAD = "OnLoad",
    SIZE_CHANGE = "OnSizeChanged",
    UPDATE = "OnUpdate",

    VISIBLE_SHOW = "OnShow",
    VISIBLE_HIDE = "OnHide",

    KEY_DOWN = "OnKeyDown",
    KEY_UP = "OnKeyUp",
    KEY_CHAR = "OnChar",

    MOUSE_CLICK = "OnClick",
    MOUSE_CLICK_DOUBLE = "OnDoubleClick",
    MOUSE_DOWN = "OnMouseDown",
    MOUSE_UP = "OnMouseUp",
    MOUSE_WHEEL = "OnMouseWheel",

    MOUSE_DRAG_START = "OnDragStart",
    MOUSE_DRAG_STOP = "OnDragStop",
    MOUSE_DRAG_DROP = "OnReceiveDrag",
};

Frame.frameTypes = {
    FRAME = "frame"
};

function Frame:Constructor(frameType, inheritedFrames)
    frameType = frameType or Frame.frameTypes.FRAME;
    frameType = string.lower(frameType);
    if not Tables.LookupValue(Frame.frameTypes, frameType) then
        error("Unrecognized frameType: " .. frameType);
    end;
    self.type = frameType;
    if type(inheritedFrames) == "string" then
        self.inheritedFrames = { string.split(",", inheritedFrames) };
    else
        self.inheritedFrames = inheritedFrames or {};
    end;
    self.rawFrame = CreateFrame(self.type, nil, nil, string.join(",", self.inheritedFrames));
end;

function Frame:GetFrame()
    return self.rawFrame;
end;

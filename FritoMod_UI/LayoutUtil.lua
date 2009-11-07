if nil ~= require then
    require "FritoMod_Functional/basic";
end;

LayoutUtil = {
    direction = {
        HORIZONTAL = "horizontal", 
        VERTICAL = "vertical",
    },

    alignment = {
        LEFT = "first",
        CENTER = "center",
        RIGHT = "last",

        TOP = "first",
        MIDDLE = "center",
        BOTTOM = "last",
    },

    points = {
        TOPLEFT = "topleft",
        TOP = "top",
        TOPRIGHT = "topright",
        RIGHT = "right",
        BOTTOMRIGHT = "bottomright",
        BOTTOM = "bottom",
        BOTTOMLEFT = "bottomleft",
        LEFT = "left"
    },

    flow = {
        FORWARD = "forward",
        BACKWARD = "backward"
    }

}

LayoutUtil.alignmentMap = {
    [LayoutUtil.direction.HORIZONTAL] = {
        [LayoutUtil.alignment.TOP] = {
            attachPoint = LayoutUtil.points.TOPLEFT,
            attachTo = LayoutUtil.points.TOPRIGHT
        },
        [LayoutUtil.alignment.MIDDLE] = {
            attachPoint = LayoutUtil.points.LEFT,
            attachTo = LayoutUtil.points.RIGHT
        },
        [LayoutUtil.alignment.BOTTOM] = {
            attachPoint = LayoutUtil.points.BOTTOMLEFT,
            attachTo = LayoutUtil.points.BOTTOMRIGHT
        }
    }, 

    [LayoutUtil.direction.VERTICAL] = {
        [LayoutUtil.alignment.LEFT] = {
            attachPoint = LayoutUtil.points.TOPLEFT,
            attachTo = LayoutUtil.points.BOTTOMLEFT
        },
        [LayoutUtil.alignment.CENTER] = {
            attachPoint = LayoutUtil.points.TOP,
            attachTo = LayoutUtil.points.BOTTOM,
        },
        [LayoutUtil.alignment.RIGHT] = {
            attachPoint = LayoutUtil.points.TOPRIGHT,
            attachTo = LayoutUtil.points.BOTTOMRIGHT
        },
    }
}
local LayoutUtil = LayoutUtil

function LayoutUtil:GetFrame(frame)
    if type(frame) == "table" and IsCallable(frame.GetFrame) then
        return frame:GetFrame()
    end;
    if type(frame) == "string" then
        return getglobal(frame)
    end;
    return frame
end;

function LayoutUtil:Chain(parentFrame, frames, direction, alignment, flow, gap, initialX, initialY)
    parentFrame = LayoutUtil:GetFrame(parentFrame)
    local previousChild = nil
    local offsetX, offsetY = 0, 0
    if direction == LayoutUtil.direction.HORIZONTAL then
        offsetX = gap
    else
        offsetY = -gap
    end
    if not initialX then
        initialX = 0
    end
    if not initialY then 
        initialY = 0
    end;
    for i, child in ipairs(frames) do
        child = LayoutUtil:GetFrame(child)
        child:ClearAllPoints()
        if previousChild then
            if flow == LayoutUtil.flow.FORWARD then
                LayoutUtil:Align(direction, child, previousChild, alignment, offsetX, offsetY)
            else
                error("Backward flow NYI");
            end;
        else
            -- This is the first child, so it's aligned relative to the frame.
            local attachments = LayoutUtil:GetAttachmentPoints(direction, alignment)
            -- Intentionally stack the anchor points.
            child:SetPoint(attachments.attachPoint, parentFrame, attachments.attachPoint, initialX, initialY)
        end;
        previousChild = child
    end;
end;

function LayoutUtil:GetAttachmentPoints(direction, alignment)
    local attachments = LayoutUtil.alignmentMap[direction][alignment]
    if not attachments then
        error("LayoutUtil:GetAttachmentPoints given bad direction/alignment - " ..
            "direction:'" .. direction .. "', '" .. alignment .. "'"
        );
    end
    return attachments
end;

function LayoutUtil:Align(direction, frame, relativeFrame, alignment, offsetX, offsetY)
    if not direction then
        direction = LayoutUtil.direction.VERTICAL
    end
    if not alignment then
        if direction == LayoutUtil.direction.HORIZONTAL then
            alignment = LayoutUtil.alignment.TOP
        else
            alignment = LayoutUtil.alignment.LEFT
        end
    end;
    if not offsetX then
        offsetX = 0
    end;
    if not offsetY then
        offsetY = 0
    end;

    local attachments = LayoutUtil:GetAttachmentPoints(direction, alignment)

    frame = LayoutUtil:GetFrame(frame)
    relativeFrame = LayoutUtil:GetFrame(relativeFrame)

    frame:SetPoint(attachments.attachPoint, relativeFrame, attachments.attachTo, offsetX, offsetY)
end;

local function DoAlign(direction, alignment, frame, relativeFrame, offsetX, offsetY)
    return LayoutUtil:Align(direction, frame, relativeFrame, alignment, offsetX, offsetY)
end;

function LayoutUtil:AlignHorizontal(...)
    return DoAlign(LayoutUtil.direction.HORIZONTAL, ...)
end;

function LayoutUtil:AlignHorizontalTop(...)
    return DoAlign(LayoutUtil.direction.HORIZONTAL, LayoutUtil.alignment.TOP, ...)
end;

function LayoutUtil:AlignHorizontalMiddle(...)
    return DoAlign(LayoutUtil.direction.HORIZONTAL, LayoutUtil.alignment.MIDDLE, ...)
end;

function LayoutUtil:AlignHorizontalBottom(...)
    return DoAlign(LayoutUtil.direction.HORIZONTAL, LayoutUtil.alignment.BOTTOM, ...)
end;

function LayoutUtil:AlignVertical(...)
    return DoAlign(LayoutUtil.direction.VERTICAL, ...)
end;

function LayoutUtil:AlignVerticalLeft(...)
    return DoAlign(LayoutUtil.direction.VERTICAL, LayoutUtil.alignment.LEFT, ...)
end;

function LayoutUtil:AlignVerticalCenter(...)
    return DoAlign(LayoutUtil.direction.VERTICAL, LayoutUtil.alignment.CENTER, ...)
end;

function LayoutUtil:AlignVerticalRight(...)
    return DoAlign(LayoutUtil.direction.VERTICAL, LayoutUtil.alignment.RIGHT, ...)
end;

LayoutUtil = {
    alignment = {
        HORIZONTAL = "horizontal", 
        VERTICAL = "vertical",
    },

    opposingAlignment = {
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
    [LayoutUtil.alignment.HORIZONTAL] = {
        [LayoutUtil.opposingAlignment.TOP] = {
            attachPoint = LayoutUtil.points.TOPLEFT,
            attachTo = LayoutUtil.points.TOPRIGHT
        },
        [LayoutUtil.opposingAlignment.MIDDLE] = {
            attachPoint = LayoutUtil.points.LEFT,
            attachTo = LayoutUtil.points.RIGHT
        },
        [LayoutUtil.opposingAlignment.BOTTOM] = {
            attachPoint = LayoutUtil.points.BOTTOMLEFT,
            attachTo = LayoutUtil.points.BOTTOMRIGHT
        }
    }, 

    [LayoutUtil.alignment.VERTICAL] = {
        [LayoutUtil.opposingAlignment.LEFT] = {
            attachPoint = LayoutUtil.points.TOPLEFT,
            attachTo = LayoutUtil.points.BOTTOMLEFT
        },
        [LayoutUtil.opposingAlignment.CENTER] = {
            attachPoint = LayoutUtil.points.TOP,
            attachTo = LayoutUtil.points.BOTTOM,
        },
        [LayoutUtil.opposingAlignment.RIGHT] = {
            attachPoint = LayoutUtil.points.TOPRIGHT,
            attachTo = LayoutUtil.points.BOTTOMRIGHT
        },
    }
}
local LayoutUtil = LayoutUtil

function LayoutUtil:GetFrame(frame)
    if FritoLib.OOP.inherits(frame, DisplayObject) then
        return frame:GetFrame()
    end;
    if type(frame) == "string" then
        return getglobal(frame)
    end;
    return frame
end;

function LayoutUtil:Chain(parentFrame, frames, alignment, opposingAlignment, flow, gap, initialX, initialY)
    parentFrame = LayoutUtil:GetFrame(parentFrame)
    local previousChild = nil
    local offsetX, offsetY = 0, 0
    if alignment == LayoutUtil.alignment.HORIZONTAL then
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
        if previousChild then
            if flow == LayoutUtil.flow.FORWARD then
                LayoutUtil:Align(alignment, child, previousChild, opposingAlignment, offsetX, offsetY)
            else
                error("Backward flow NYI");
            end;
        else
            -- This is the first child, so it's aligned relative to the frame.
            local attachments = LayoutUtil:GetAttachmentPoints(alignment, opposingAlignment)
            -- Intentionally stack the anchor points.
            child:SetPoint(attachments.attachPoint, parentFrame, attachments.attachPoint, initialX, initialY)
        end;
        previousChild = child
    end;
end;

function LayoutUtil:GetAttachmentPoints(alignment, opposingAlignment)
    local attachments = LayoutUtil.alignmentMap[alignment][opposingAlignment]
    if not attachments then
        error("LayoutUtil:GetAttachmentPoints given bad alignment/opposingAlignment - " ..
            "alignment:'" .. alignment .. "', '" .. opposingAlignment .. "'"
        );
    end
    return attachments
end;

function LayoutUtil:Align(alignment, frame, relativeFrame, opposingAlignment, offsetX, offsetY)
    if not alignment then
        alignment = LayoutUtil.alignment.VERTICAL
    end
    if not opposingAlignment then
        if alignment == LayoutUtil.alignment.HORIZONTAL then
            opposingAlignment = LayoutUtil.opposingAlignment.TOP
        else
            opposingAlignment = LayoutUtil.opposingAlignment.LEFT
        end
    end;
    if not offsetX then
        offsetX = 0
    end;
    if not offsetY then
        offsetY = 0
    end;

    local attachments = LayoutUtil:GetAttachmentPoints(alignment, opposingAlignment)

    frame = LayoutUtil:GetFrame(frame)
    relativeFrame = LayoutUtil:GetFrame(relativeFrame)

    frame:SetPoint(attachments.attachPoint, relativeFrame, attachments.attachTo, offsetX, offsetY)
end;

local function DoAlign(alignment, opposingAlignment, frame, relativeFrame, offsetX, offsetY)
    return LayoutUtil:Align(alignment, frame, relativeFrame, opposingAlignment, offsetX, offsetY)
end;

function LayoutUtil:AlignHorizontal(...)
    return DoAlign(LayoutUtil.alignment.HORIZONTAL, ...)
end;

function LayoutUtil:AlignHorizontalTop(...)
    return DoAlign(LayoutUtil.alignment.HORIZONTAL, LayoutUtil.opposingAlignment.TOP, ...)
end;

function LayoutUtil:AlignHorizontalMiddle(...)
    return DoAlign(LayoutUtil.alignment.HORIZONTAL, LayoutUtil.opposingAlignment.MIDDLE, ...)
end;

function LayoutUtil:AlignHorizontalBottom(...)
    return DoAlign(LayoutUtil.alignment.HORIZONTAL, LayoutUtil.opposingAlignment.BOTTOM, ...)
end;

function LayoutUtil:AlignVertical(...)
    return DoAlign(LayoutUtil.alignment.VERTICAL, ...)
end;

function LayoutUtil:AlignVerticalLeft(...)
    return DoAlign(LayoutUtil.alignment.VERTICAL, LayoutUtil.opposingAlignment.LEFT, ...)
end;

function LayoutUtil:AlignVerticalCenter(...)
    return DoAlign(LayoutUtil.alignment.VERTICAL, LayoutUtil.opposingAlignment.CENTER, ...)
end;

function LayoutUtil:AlignVerticalRight(...)
    return DoAlign(LayoutUtil.alignment.VERTICAL, LayoutUtil.opposingAlignment.RIGHT, ...)
end;

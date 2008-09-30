Box = OOP.Class(DisplayObjectContainer);
local Box = Box;

Box.direction = LayoutUtil.direction
Box.alignment = LayoutUtil.alignment
Box.flow = LayoutUtil.flow

Box.defaultValues = {
    Direction = Box.direction.HORIZONTAL,
    FlowDirection = Box.flow.FORWARD,
    Alignment = Box.alignment.TOP,
    Gap = 3,
}

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function Box:__Init()
    Box.super.__Init(self);
end;

-------------------------------------------------------------------------------
--
--  Getters and Setters
--
-------------------------------------------------------------------------------

StyleClient.AddComputedValue(Box, "FlowDirection", StyleClient.CHANGE_LAYOUT);
StyleClient.AddComputedValue(Box, "Direction", StyleClient.CHANGE_SIZE);
StyleClient.AddComputedValue(Box, "Gap", StyleClient.CHANGE_SIZE);
StyleClient.AddComputedValue(Box, "Alignment", StyleClient.CHANGE_LAYOUT);

-------------------------------------------------------------------------------
--
--  Overridden Methods: StyleClient
--
-------------------------------------------------------------------------------

function Box:FetchDefaultFromTable(valueName)
    return Box.defaultValues[valueName] or
        Box.super.FetchDefaultFromTable(self, valueName);
end;

-------------------------------------------------------------------------------
--
--  Overridden Methods: Invalidating
--
-------------------------------------------------------------------------------

function Box:Measure()
    Box.super.Measure(self);
    local direction = self:GetDirection();
    for child in self:Iter() do
        if direction == Box.direction.HORIZONTAL then
            self.measuredWidth = self.measuredWidth + child:GetWidth();
            self.measuredHeight = max(self.measuredHeight, child:GetHeight());
        else
            self.measuredWidth = max(self.measuredWidth, child:GetWidth());
            self.measuredHeight = self.measuredHeight + child:GetHeight();
        end;
    end;
    local totalGap = self:GetGap() * (self:GetNumChildren() - 1);
    if direction == Box.direction.HORIZONTAL then
        self.measuredWidth = self.measuredWidth + totalGap;
    else
        self.measuredHeight = self.measuredHeight + totalGap;
    end;
end;

function Box:UpdateLayout()
    debug("Box:UpdateLayout")
    LayoutUtil:Chain(
        self,
        self.children,
        self:GetDirection(), 
        self:GetAlignment(), 
        self:GetFlowDirection(), 
        self:GetGap()
    );
    Box.super.UpdateLayout(self)
end;

if nil ~= require then
    require "fritomod/Functions";
    require "fritomod/OOP-Class"
end;

WoW=WoW or {};

WoW.Cursor=OOP.Class();
local Cursor=WoW.Cursor;

function Cursor:Constructor(world)
    self.world=world;
end;

function Cursor:GetWorld()
    return self.world;
end;

function Cursor:AssertWorld(frame)
    assert(frame.GetWorld, "Frame must be created by FritoMod; real frames aren't supported");
    assert(frame:GetWorld()==self:GetWorld(), "Frame must be of the same world");
end;

function Cursor:Enter(frame)
    if self.hoveredFrame == frame then
        return Noop;
    end;
    if self.hoveredFrame then
        self:Leave();
    end;
    self:AssertWorld(frame);
    self.hoveredFrame=frame;
    self.hoveredFrame:FireEvent("OnEnter");
    return Functions.OnlyOnce(self, "Leave", frame);
end;

function Cursor:Down(frame)
    self:AssertWorld(frame);
    self:Enter(frame);
    self.hoveredFrame:FireEvent("OnMouseDown");
    return Functions.OnlyOnce(function()
        self.hoveredFrame:FireEvent("OnMouseUp");
    end);
end;

function Cursor:Click(frame)
    self:AssertWorld(frame);
    self:Enter(frame);
    self.hoveredFrame:FireEvent("OnClick");
end;

function Cursor:Leave()
    if not self.hoveredFrame then
        return;
    end;
    local oldFrame=self.hoveredFrame;
    self.hoveredFrame=nil;
    oldFrame:FireEvent("OnLeave");
end;

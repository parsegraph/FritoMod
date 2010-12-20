-- Labs.FirstAid shows a pulsing first-aid icon that correlates with the player's health.
-- As the player's health decreases, the icon will beat faster. At critically low health,
-- the icon will turn red.

if nil ~= require then
    require "wow/Frame-Animation";
    require "wow/Frame-Layout";

    require "Lists";
    require "Frames";
    require "Events";
end;

Labs=Labs or {};

function Labs.FirstAid()
    local frame=CreateFrame("Frame", nil, UIParent);

    --frame:SetPoint("top", UIParent, "top");
    local b=HeadlessBuilders;
    local bu=Builders;
    local center=frame:CreateTexture();
    center:SetDrawLayer("background");
    bu.Square(center,24);
    bu.Center(center);

    local ag=center:CreateAnimationGroup();
    local ca=ag:CreateAnimation("alpha");
    ca:SetChange(-1);
    ag:Play();
    ag:SetLooping("repeat");

    local block = Curry(Lists.Build, {
          b.Square(48),
          b.Color("white"),
          b.Alpha(.8),
          Functions.Cycle(
             b.Northeast(center, -2),
             b.Northwest(center, -2),
             b.Southwest(center, -2),
             b.Southeast(center, -2)
          )
    });
    local pulse = Curry(Lists.Build, {
          b.Square(20),
          b.Color("red"),
          b.Center(center);
    });
    local anims={};
    local opacities={};
    for i=1,4 do
       local b=block(frame:CreateTexture());
       b:SetDrawLayer("overlay");
       local p=pulse(frame:CreateTexture());
       local ag=p:CreateAnimationGroup();
       ag:SetLooping("repeat");
       local a=ag:CreateAnimation("alpha");
       a:SetChange(-1);
       a:SetOrder(1);
       table.insert(opacities, a);
       table.insert(anims, a);
       a=ag:CreateAnimation("translation");
       a:SetOrder(1);
       a:SetParent(ag);
       local sz=18+40;
       if i==1 then
          a:SetOffset(0,sz);
       elseif i==2 then
          a:SetOffset(-sz,0);
       elseif i==3 then
          a:SetOffset(0,-sz);
       else
          a:SetOffset(sz,0);
       end
       a:SetSmoothing("out");
       table.insert(anims, a);
       ag:Play();
    end;
    local function SetDurations()
       local pct=UnitHealth("player") / UnitHealthMax("player");
       local duration=max(.2, .1 + .9 * (pct-.2))
       Lists.Each(anims, "SetDuration", duration*1.5);
       Lists.Each(opacities, "SetChange", -pct - .5);
    end;
    SetDurations();

    frame.f=Events.UNIT_HEALTH(function(unitID)
          if unitID ~= "player" then
             return;
          end;
          SetDurations();
    end);

    return function()
        frame.f();
        frame:Hide();
        frame:SetParent(nil);
        frame:ClearAllPoints();
    end;
end;

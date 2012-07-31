if nil ~= require then
    require "fritomod/Tables";
end;

Labs=Labs or {};

function Labs.IconSpellCounts()
    local n="Frito.IconSpellCounts";
    local parent=Curry(Tables.Value, Frames, n);
    if parent() and parent().remover then
       parent().remover();
    end;
    parent(CreateFrame("Frame",nil,UIParent));

    local counters={};

    local size=48;
    local function CreateCounter(spell)
       local frame=CreateFrame("Frame",nil,parent());
       Builders.Square(frame, size);
       frame:SetBackdrop({
             edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
             tile = true, tileSize = 16, edgeSize = 16,
             insets = { left = 2, right = 2, top = 2, bottom = 2 }
       });
       local icon=frame:CreateTexture(nil, "BACKGROUND");
       icon:SetWidth(size-4);
       icon:SetHeight(size-4);
       icon:SetPoint("center");
       local iconTexture=select(3, GetSpellInfo(spell));
       icon:SetTexture(iconTexture);
       icon:SetTexCoord(.03,.97,.03,.97);


       local tint=frame:CreateTexture(nil, "BORDER");
       tint:SetAllPoints(icon);
       Builders.Color(tint, "red");

       local count=frame:CreateFontString();
       count:SetFont("Fonts\\FRIZQT__.TTF", 24, "outline");
       count:SetPoint("center");

       local maxCount=frame:CreateFontString();
       maxCount:SetFont("Fonts\\FRIZQT__.TTF", 10, "outline");
       Anchors.Share(maxCount, frame, "bottomright", -4);

       local progress=frame:CreateTexture();
       progress:SetHeight(8);
       progress:SetAlpha(.6);
       progress:SetPoint("bottomleft", frame, "topleft");

       table.insert(counters, function()
             local cost=select(4, GetSpellInfo(spell));
             local mana=UnitPower("player");
             local maxMana=UnitPowerMax("player");
             if cost==0 then
                progress:Hide();
                tint:Hide();
                count:SetText("-");
                count:SetTextColor(0,1,0);
             else
                local possible=floor(maxMana/cost);
                local current=floor(mana/cost);
                maxCount:SetText(possible);
                count:SetText(current);
                maxCount:SetAlpha(1);
                if current==0 then
                   progress:Show();
                   progress:SetWidth(max(1, size * ((mana % cost)/cost)));
                   count:SetTextColor(1,.1,.1);
                elseif current<possible then
                   progress:Show();
                   progress:SetWidth(max(1, size * ((mana % cost)/cost)));
                   count:SetTextColor(1,1,1);
                else
                   maxCount:SetAlpha(.7);
                   progress:Hide();
                   count:SetTextColor(0,1,0);
                end;
                local pct=mana/maxMana;
                tint:Hide();
                if pct==1 then
                   Builders.Color(progress, "white", 0);
                elseif pct > .7 then
                   Builders.Color(progress, "green", .6);
                elseif pct > .4 then
                   Builders.Color(progress, "yellow", .6);
                else
                   Builders.Color(progress, "red");
                   tint:Show();
                   tint:SetAlpha(.5*(1-(pct / .4)));
                end;
             end;
       end);

       return frame;
    end;

    local last=Anchors.Named(n);
    local spells={"Greater Heal", "Holy Nova", "Flash Heal","Dispel Magic","Smite"};
    for _, spell in ipairs(spells) do
       local f=CreateCounter(spell);
       Anchors.Touch(f, last, "right",1);
       last=f;
    end;

    Lists.CallEach(counters);
    local remover=Timing.Every(.1, Lists.CallEach, counters);
    parent().remover=function()
       if remover then
          remover();
       end;
       parent():Hide();
    end;
end;

-- vim: set ts=4 sw=4 et :

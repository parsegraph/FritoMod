-- Handy development tool: shows info about the object under the cursor.

if nil ~= require then
    require "wow/Frame-Layout";
    require "wow/api/Frame";
    require "wow/api/UIParent";

    require "fritomod/Functions";
    require "fritomod/OOP-Class";
    require "fritomod/Lists";
    require "fritomod/Frames";
    require "fritomod/Frames-Mouse";
    require "fritomod/Anchors";
end;

Labs=Labs or {};

local TitleFrame=OOP.Class();

function TitleFrame:Constructor(parent)
    self.frameTypeText=Frames.Text(parent, "friz", 14);
    Frames.Color(self.frameTypeText, "gold");

    self.nameText=Frames.Text(parent, "friz", 10);
    Anchors.VFlipBottom(self.nameText, self.frameTypeText, 4);
end;

function TitleFrame:Set(f)
    self.frameTypeText:Hide();
    self.nameText:Hide();
    if not f then
        return;
    end;
    if f:GetObjectType() then
        self.frameTypeText:Show();
        self.frameTypeText:SetText(f:GetObjectType());
    end;
    if f:GetName() then
        self.nameText:Show();
        self.nameText:SetText(('"%s"'):format(f:GetName()));
    end;
end;

function TitleFrame:Top()
    if self.frameTypeText:IsShown() then
        return self.frameTypeText;
    end;
end;

function TitleFrame:Bottom()
    if self.nameText:IsShown() then
        return self.nameText;
    else
        return self.frameTypeText;
    end;
end;

local PointFrame=OOP.Class();

function PointFrame:Constructor(parent)
    self.container=CreateFrame("Frame", nil, parent);
    self.container:SetHeight(40);
    parent=self.container;
    self.anchorText=Frames.Text(parent, "friz", 12);
    self.refText=Frames.Text(parent, "friz", 10);

    self.anchorText:SetJustifyH("left");
    self.refText:SetJustifyH("left");

    Anchors.ShareTop(self.anchorText);
    Anchors.VFlipBottom(self.refText, self.anchorText);
end;

function PointFrame:Set(frame, index)
    self.container:Hide();
    self.anchorText:Hide();
    self.refText:Hide();
    if not frame then
        return;
    end;
    local anchor, ref, anchorTo, gapX, gapY=frame:GetPoint(index);
    if not anchor then
        return;
    end;
    self.container:Show();
    self.anchorText:Show();
    if not anchorTo then
        anchorTo="("..anchor..")";
    end;
    self.anchorText:SetText(("%s : %s"):format(anchor, anchorTo));
    if not ref then
        ref=UIParent;
    end;
    local n, t;
    if ref:GetName() then
        n=' "'..ref:GetName()..'"';
    elseif ref==frame:GetParent() then
        n=" (parent)";
    end;
    t=ref:GetObjectType();
    self.refText:Show();
    self.refText:SetText(("[%s%s]"):format(t, n));
end;

function PointFrame:GetContainer()
    if self.container:IsShown() then
        return self.container;
    end;
end;

FrameFinder=OOP.Class();

function FrameFinder:Constructor()
    self.container=CreateFrame("Frame");
    self.container:SetFrameStrata("dialog");
    Frames.Size(self.container, 300, 200);
    Frames.Backdrop(self.container, "black");

    local close=CreateFrame("Button", nil, self.container);
    Frames.Button(close, "close");
    Frames.Size(close, 15);
    Anchors.Share(close, "topright");
    Callbacks.Click(close, self.container, "Hide");

    self.titleFrame=TitleFrame:New(self.container);

    self.points={};
end;

function FrameFinder:GetContainer()
    return self.container;
end;

function FrameFinder:Set(f)
    if self.target == f then
        return;
    end;
    self.target=f;
    self.titleFrame:Set(f);
    local frames={};
    if self.titleFrame:Top() then
        table.insert(frames, self.titleFrame:Top());
        table.insert(frames, self.titleFrame:Bottom());
    end;
    if f:GetNumPoints() > 0 then
        local pointFrames={};
        Lists.Each(self.points, function(p)
            p:Set();
        end);
        for i=1, f:GetNumPoints() do
            local point=self.points[i]
            if not point then
                point=PointFrame:New(self.container);
                table.insert(self.points, point);
            end;
            point:Set(f, i);
            if point:GetContainer() then
                table.insert(pointFrames, point:GetContainer());
            end;
        end;
        Lists.FlipMarch(pointFrames, Anchors.VFlipBottom);
        table.insert(frames, pointFrames[1]);
        table.insert(frames, pointFrames[#pointFrames]);
    end;
    Lists.FlipMarch(frames, function(a, b)
        if a ~= b then
            Anchors.VFlipBottom(a, b);
        end;
    end);
    Anchors.ShareTop(frames[1]);
end;

function Labs.FrameFinder()
    local finder=FrameFinder:New();

    local f=finder:GetContainer();

    f:SetParent(UIParent);
    f:SetPoint("center");
    Frames.InstantDraggable(f);
    f:Hide();

    Slash.Register("ff", Frames.ToggleShow, f);
    Callbacks.ShowFrame(f, Timing.Every, .3, function()
        if not IsAltKeyDown() then
            return;
        end;
        local focusedFrame = GetMouseFocus()
        if focusedFrame then
            finder:Set(focusedFrame);
        end
    end);
end

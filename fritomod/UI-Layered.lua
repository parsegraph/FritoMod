if nil ~= require then
    require "wow/FontString";
    require "wow/Frame-Container";
    require "wow/Frame-Layer";
    require "wow/Frame-Alpha";

    require "fritomod/Functions";
    require "fritomod/Lists";
    require "fritomod/Ordering";
    require "fritomod/Anchors";
    require "fritomod/Tables";
    require "fritomod/Frames";
    require "fritomod/OOP-Class";
    require "fritomod/Media-Color";
    require "fritomod/Media-Font";
    require "fritomod/Media-Texture";
end;

UI = UI or {};

local Layered = OOP.Class("UI.Layered");
UI.Layered = Layered;

local DRAW_LAYERS = {
    BACKGROUND = 0,
    BORDER = 1,
    ARTWORK = 2,
    OVERLAY = 3
    -- We don't use highlight since it has special behaviors if
    -- mouse input is enabled.
};

local REVERSED_DRAW_LAYERS = {};
for layer, offset in pairs(DRAW_LAYERS) do
    REVERSED_DRAW_LAYERS[offset] = layer;
end;

local SUBLEVELS = 16;

function Layered:Constructor(parent, baseLayer)
    assert(type(baseLayer) == "string" or baseLayer == nil,
        "baseLayer must a string");
    self.frame = Frames.New(parent);
    self:AddDestructor(self.frame);

    baseLayer = baseLayer or "BACKGROUND";
    baseLayer = baseLayer:upper();
    assert(baseLayer ~= "HIGHLIGHT",
        "HIGHLIGHT base layer is not allowed");
    self.baseLayer = DRAW_LAYERS[baseLayer];
    assert(self.baseLayer ~= nil,
        "Unknown or invalid layer name: "..baseLayer);

    self.layers = {};

    self.order = Ordering:New();
    self:AddDestructor(self.order);
end;

function Layered:AddTexture(name, ...)
    return self:Add(name, Frames.Texture(self, ...));
end;

function Layered:AddColor(name, ...)
    return self:Add(name, Frames.Color(self, ...));
end;

function Layered:AddText(name, ...)
    local element = Frames.Text(self, ...);
    Anchors.ShareAll(element);
    return self:Add(name, element);
end;

function Layered:Add(name, layer)
    self.order:Order(name);
    self.layers[name] = layer;

    self:Update();

    return Functions.OnlyOnce(self, "Remove", name);
end;

function Layered:Get(name)
    return self.layers[name];
end;

function Layered:Raise(name)
    self.order:Raise(name);
    self:Update();
end;

function Layered:Lower(name)
    self.order:Lower(name);
    self:Update();
end;

function Layered:Order(...)
    self.order:Order(...);
    self:Update();
end;

function Layered:GetOrder()
    return Tables.Clone(self.order:Get());
end;

local function ConvertToDrawLayer(count)
    local layer = math.floor(count / SUBLEVELS);
    local drawLayer = REVERSED_DRAW_LAYERS[layer];
    local subLayer = count % SUBLEVELS - (SUBLEVELS / 2);
    assert(drawLayer ~= nil, "drawLayer was out of bounds: "..tostring(layer));
    assert(subLayer >= -(SUBLEVELS / 2) and subLayer <= (SUBLEVELS / 2) - 1,
        "subLayer out of bounds: "..tostring(subLayer));
    return drawLayer, subLayer;
end;

function Layered:Update()
    local count = self.baseLayer * SUBLEVELS;
    for _, name in self.order:Iterator() do
        local layer = self.layers[name];
        if layer then
            local l, sl = ConvertToDrawLayer(count);
            tracef("Layered - Name:%s Layer:%s Sublayer:%d", tostring(name), l, sl);
            layer:SetDrawLayer(l, sl);
            count = count + 1;
        end;
    end;
end;

function Layered:Remove(name)
    local layer = self.layers[name];
    self.layers[name] = nil;
    if layer then
        Anchors.Clear(layer);
        self:Update();
        return;
    end;
end;

function Layered:RemoveOrder(name)
    self:Remove(name);
    self.order:Remove(name);
end;

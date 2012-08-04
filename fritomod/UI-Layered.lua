if nil ~= require then
    require "wow/FontString";
    require "wow/Frame-Container";
    require "wow/Frame-Layer";
    require "wow/Frame-Alpha";

    require "fritomod/Functions";
    require "fritomod/Lists";
    require "fritomod/Anchors";
    require "fritomod/Tables";
    require "fritomod/Frames";
    require "fritomod/OOP-Class";
    require "fritomod/Media-Color";
    require "fritomod/Media-Font";
    require "fritomod/Media-Texture";
end;

UI = UI or {};

local Layered = OOP.Class();
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

    baseLayer = baseLayer or "BACKGROUND";
    baseLayer = baseLayer:upper();
    assert(baseLayer ~= "HIGHLIGHT",
        "HIGHLIGHT base layer is not allowed");
    self.baseLayer = DRAW_LAYERS[baseLayer];
    assert(self.baseLayer ~= nil,
        "Unknown or invalid layer name: "..baseLayer);

    self.layers = {};

    self.order = {};
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
    if not Lists.Contains(self.order, name) then
        Lists.Insert(self.order, name);
    end;
    self.layers[name] = layer;

    self:Update();

    return Functions.OnlyOnce(self, "Remove", name);
end;

function Layered:Get(name)
    return self.layers[name];
end;

function Layered:Raise(name)
    Lists.Remove(self.order, name);
    Lists.Insert(self.order, name);
    self:Update();
end;

function Layered:Lower(name)
    Lists.Remove(self.order, name);
    Lists.Unshift(self.order, name);
    self:Update();
end;

function Layered:Order(order, ...)
    if type(order) ~= "table" or select("#", ...) > 0 or #order == 0 then
        return self:Order({order, ...});
    end;

    do
        -- Do a quick check for duplicates in their names.
        local names = {};
        for _, name in ipairs(order) do
            assert(not names[name], "Ordering names must be unique; "
            .. "duplicate ordering names are ambiguous and not allowed");
            names[name] = true;
        end;
    end;

    local ourIndex = 1;
    local theirIndex = 1;
    while theirIndex <= #order do
        if ourIndex > #self.order then
            -- No more elements in the original ordering, so just start
            -- pushing their elements to the end.
            while theirIndex <= #order do
                Lists.Push(self.order, order[theirIndex]);
                theirIndex = theirIndex + 1;
            end;
            break;
        end;
        -- Still elements in both lists
        assert(ourIndex <= #self.order);
        assert(theirIndex <= #order);

        -- Look to see if their ordering contains our current element
        local i = Lists.IndexOf(order, self.order[ourIndex]);

        if i ~= nil then
            -- We've found an element in both the original ordering
            -- and the partial ordering, so move any elements that
            -- come before this one in their order.
            --
            -- For example, imagine our ordering:
            -- A B D C E
            -- And their ordering:
            -- C D
            --
            -- Once we find D in our ordering, we'll also find it in
            -- theirs. We'll add every element to our ordering that
            -- comes before D in their ordering.
            local offset = 0;
            for j=theirIndex, i - 1 do
                -- Remove their element from our ordering, regardless
                -- of its location.
                Lists.Remove(self.order, order[j]);

                -- Replace that same element at the current location (which
                -- is offset to ensure multiple insertions don't end up
                -- backwards)
                Lists.InsertAt(self.order, ourIndex + offset, order[j]);

                offset = offset + 1;
            end;

            -- Advance both iterators past the area we just worked with
            local advancedOurIndex = ourIndex + offset + 1;
            assert(ourIndex < advancedOurIndex,
                "ourIndex failed to advance");
            ourIndex = advancedOurIndex;

            local advancedTheirIndex = i + 1;
            assert(theirIndex < advancedTheirIndex,
                "theirIndex failed to advance");
            theirIndex = advancedTheirIndex;
        else
            -- The partial ordering provides no information about
            -- this element, so just continue
            ourIndex = ourIndex + 1;
        end;
    end;

    -- Just to make sure iteration ended as expected
    assert(theirIndex > #order);

    self:Update();
end;

function Layered:GetOrder()
    return Tables.Clone(self.order);
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
    for _, name in ipairs(self.order) do
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
    Lists.Remove(self.order, name);
end;

function Layered:Destroy()
    Tables.EachKey(self.order, self, "RemoveOrder");
    Frames.Destroy(self.frame);
end;

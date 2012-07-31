if nil ~= require then
        require "fritomod/OOP-Class";
    require "fritomod/UI-Icon";
    require "fritomod/UI-Bar";
    require "fritomod/Amounts-Mechanics";
    require "fritomod/Media-Texture";
    require "fritomod/Frames";
    require "fritomod/Anchors";
    require "fritomod/Metatables-StyleClient";
end;

UI = UI or {};

local SpellCounter = OOP.Class();
UI.SpellCounter = SpellCounter;

function SpellCounter:Constructor(parent, style)
    parent = Frames.AsRegion(parent);

    self.style = Metatables.StyleClient(style);

    -- TODO Don't hardcode the size here
    local width = 48;

    self.icon = UI.Icon:New(parent, {
        drawLayer = "BACKGROUND"
    });
    Frames.WH(self.icon, width);

    self.mana = Amounts.Energy("player");
    -- We need to register at least one listener so that self.mana has values
    self.mana:OnChange(self, "Update");

    -- Available casts
    self.casts = Mechanics.Amount:New();

    -- Fraction of mana till next cast
    self.fractionalCasts = Mechanics.Amount:New();
    self.fractionalCasts:SetBounds(0, 1);

    -- Progress represents the progress (in terms of mana regen) to the next cast
    -- TODO Update the style here
    self.progress = UI.Bar:New(parent, {});
    self.progress:SetAmount(self.fractionalCasts);
    Frames.WH(self.progress, width, 8);

    self.tint = Frames.Color(self.icon, "red", 0);
    self.tint:SetDrawLayer("BACKGROUND", 1);

    -- Count will hold the number of available casts remaining for the spell
    self.count = Frames.Text(self.icon, "friz", 24, "outline");
    self.count:SetDrawLayer("ARTWORK");
    Anchors.Center(self.count);
    self.casts:OnValueChanged(self.count, "SetText");

    -- MaxCount will hold the maximum number of casts possible
    self.maxCount = Frames.Text(self.icon, "friz", 10, "outline");
    self.maxCount:SetDrawLayer("ARTWORK");
    Anchors.Share(self.maxCount, self.icon, "bottomright", -4);
    self.casts:OnMaxChanged(self.maxCount, "SetText");
end;

function SpellCounter:SetSpell(spell)
    self.spell = spell;
    self.icon:SetTexture(Media.spell(spell));
end

function SpellCounter:Anchor(anchor)
    return Anchors.VJustify(anchor,
        self.icon,
        self.progress);
end;

function SpellCounter:Bounds(anchor)
    local vcomp = Frames.HorizontalComponent(anchor);
    if vcomp == "BOTTOM" then
        return self.progress;
    end;
    return self.icon;
end;

function SpellCounter:Update()
    if not self.mana:HasAll() or not self.spell then
        return;
    end;

    local cost = select(4, GetSpellInfo(self.spell));
    if cost == 0 then
        -- We have a clearcasting proc or something of that nature
        Frames.Hide(self.progress);
        self.tint:Hide();
        self.count:SetText("-");
        Frames.Color(self.count, "green");
        return;
    end;

    -- Set our amount values. Setting these values will update the text
    -- automatically
    self.casts:SetAll(
        0,
        floor(self.mana:Value() / cost),
        floor(self.mana:Max() / cost)
    );
    self.fractionalCasts:SetValue((self.mana:Value() % cost) / cost);

    -- Defaults, may be overwritten later on
    self.maxCount:SetAlpha(1);
    Frames.Show(self.progress);

    if self.casts:Value() == 0 then
        -- We have no casts available
        Frames.Color(self.count, "red");
    elseif self.casts:Value() < self.casts:Max() then
        -- We're still underneath our maximum casts
        Frames.Color(self.count, "white");
    else
        -- We're at the maximum available casts
        assert(self.casts:Value() == self.casts:Max());
        self.maxCount:SetAlpha(.7);
        Frames.Hide(self.progress);
        Frames.Color(self.count, "green");
    end;

    -- Set the tint color
    local pct = self.mana:Percent();
    self.tint:Hide();
    if pct==1 then
        Frames.Color(self.progress, "white", 0);
    elseif pct > .7 then
        Frames.Color(self.progress, "green", .6);
    elseif pct > .4 then
        Frames.Color(self.progress, "yellow", .6);
    else
        Frames.Color(self.progress, "red");
        self.tint:Show();
        self.tint:SetAlpha(.5*(1-(pct / .4)));
    end;
end;

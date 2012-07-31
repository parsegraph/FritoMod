if nil ~= require then
    require "fritomod/Timing";
    require "fritomod/Anchors";
    require "fritomod/Lists";

    require "labs/UI-SpellCounter";
end;

Labs = Labs or {};

function Labs.IconSpellCounts(parent, spells)
    local counters = Lists.MapValues(spells, function(spell)
        local counter = UI.SpellCounter:New(parent);
        counter:SetSpell(spell);
        return counter;
    end);
    local ref = Anchors.HJustify("topright", counters);

    Lists.Each(counters, "Update");
    Timing.Every(.1, Lists.Each, counters, "Update");

    return ref;
end;

if nil ~= require then
    require "wow/Frame-Layout";
    require "wow/FontString";

    require "fritomod/Anchors"
end;

Frames=Frames or {};

local function Forwarded(container, f, name)
    container[name]=function()
        if IsCallable(f[name]) then
            f[name]();
        end;
    end;
end;

function Frames.OptionCategory(f, name, desc, parent)
    local container=CreateFrame("Frame", nil, UIParent);
    if not name then
        name=f.name;
    end;
    container.name=name;
    if not parent then
        parent=f.parent;
    end;
    container.parent=parent;

    Forwarded(container, f, "okay");
    Forwarded(container, f, "cancel");
    Forwarded(container, f, "default");
    Forwarded(container, f, "refresh");

    local nameText=container:CreateFontString(nil, nil, "GameFontNormalLarge");
    Anchors.Share(nameText, container, "topleft", 16);
    Anchors.Share(nameText, container, "topright", 16);
    nameText:SetJustifyH('LEFT')
    nameText:SetJustifyV('TOP')
    nameText:SetText(name);

    if desc then
        local descText=container:CreateFontString(nil, nil, "GameFontHighlightSmall");
        Anchors.VerticalFlip(descText, nameText, "bottomleft", 8);
        Anchors.VerticalFlip(descText, nameText, "bottomright", 8);
        descText:SetHeight(32);
        descText:SetJustifyH('LEFT')
        descText:SetJustifyV('TOP')
        descText:SetText(desc);
        Anchors.VerticalFlip(f, descText, "bottomleft", 16);
    else
        Anchors.VerticalFlip(f, nameText, "bottomleft", 16);
    end;
    f:SetParent(container);

    InterfaceOptions_AddCategory(container);

    return container;
end;

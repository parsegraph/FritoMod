if nil ~= require then
    require "Media";
end;

local insets=setmetatable({
    dialog = { left = 11, right = 12, top = 12, bottom = 11 },
    slider = { left = 3,  right = 3,  top = 6,  bottom = 6  },
}, {
    __index=function(self, k)
        if type(k)=="number" then
            self[k]={
                left=k,
                right=k,
                top=k,
                bottom=k
            };
            return self[k];
        end;
    end
});

local borders={};

borders.goldDialog={
    edgeFile="Interface/DialogFrame/UI-DialogBox-Gold-Border",
    bgFile = "Interface/DialogFrame/UI-DialogBox-Gold-Background", 
    edgeSize = 32,
    tile=true,
    tileSize=32,
    insets = insets.dialog
};
borders.gold=borders.goldDialog;

borders.blackdialog={
    edgeFile="Interface/DialogFrame/UI-DialogBox-Border",
    bgFile = "Interface/DialogFrame/UI-DialogBox-Background", 
    edgeSize = 32,
    tile=true,
    tileSize=32,
    insets = insets.dialog
};
borders.dialog=borders.blackdialog;
borders.black=borders.blackdialog;
borders.default=borders.blackdialog;

borders.chatbubble={
    edgeFile = "Interface/Tooltips/ChatBubble-Backdrop",
    bgFile = "Interface/Tooltips/ChatBubble-Background",
    edgeSize = 32,
    tile=true,
    tileSize=32,
    insets = insets[32]
};
borders.chat=borders.chatbubble;

borders.tooltip={
    edgeFile="Interface/Tooltips/UI-Tooltip-Backdrop",
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeSize = 16,
    tile=true,
    tileSize=16,
    insets = insets[5]
};

borders.slider={
    edgeFile="Interface/Buttons/UI-SliderBar-Border",
    bgFile = "Interface/Buttons/UI-SliderBar-Background", 
    edgeSize=8,
    tile=true,
    tileSize=8, 
    insets = insets.slider
};

Media.border(borders);
Media.SetAlias("border", "borders", "backdrop", "backdrops", "edge", "edges");

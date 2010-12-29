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

local backdrops=setmetatable({}, {
    __newindex=function(self, name, backdrop)
        -- Unix-style slashes work for Blizzard's textures, but not for
        -- custom addons. I like not having to type two characters, so
        -- we do the conversion here.
        backdrop.edgeFile=backdrop.edgeFile:gsub("/", "\\");
        if backdrop.bgFile then
            backdrop.bgFile=backdrop.bgFile:gsub("/", "\\");
        end;
        rawset(self, name, backdrop);
    end
});

backdrops.goldDialog={
    edgeFile="Interface/DialogFrame/UI-DialogBox-Gold-Border",
    bgFile  ="Interface/DialogFrame/UI-DialogBox-Gold-Background", 
    edgeSize = 32,
    tile=true,
    tileSize=32,
    insets = insets.dialog
};
backdrops.gold=backdrops.goldDialog;

backdrops.blackdialog={
    edgeFile="Interface/DialogFrame/UI-DialogBox-Border",
    bgFile  ="Interface/DialogFrame/UI-DialogBox-Background", 
    edgeSize = 32,
    tile=true,
    tileSize=32,
    insets = insets.dialog
};
backdrops.dialog=backdrops.blackdialog;
backdrops.black=backdrops.blackdialog;

backdrops.chatbubble={
    edgeFile="Interface/Tooltips/ChatBubble-Backdrop",
    bgFile  ="Interface/Tooltips/ChatBubble-Background",
    edgeSize = 32,
    tile=true,
    tileSize=32,
    insets = insets[32]
};
backdrops.chat=backdrops.chatbubble;

backdrops.tooltip={
    edgeFile="Interface/Tooltips/UI-Tooltip-Border",
    bgFile  ="Interface/Tooltips/UI-Tooltip-Background",
    edgeSize = 16,
    tile=true,
    tileSize=16,
    insets = insets[5]
};
backdrops.default=backdrops.tooltip;

backdrops.slider={
    edgeFile="Interface/Buttons/UI-SliderBar-Border",
    bgFile  ="Interface/Buttons/UI-SliderBar-Background", 
    edgeSize=8,
    tile=true,
    tileSize=8, 
    insets = insets.slider
};


Media.backdrop(backdrops);
Media.SetAlias("backdrops", "border", "borders", "edge", "edges");

if nil ~= require then
    require "fritomod/OOP-Class";
    require "fritomod/Frames";
    require "fritomod/Anchors";
    require "fritomod/Callbacks-Mouse";
    require "fritomod/Media-Button";
    require "fritomod/Media-Backdrop";
    require "fritomod/Metatables-StyleClient";
    require "fritomod/UI-List";
end;

UI = UI or {};
UI.Window = OOP.Class();
local Window = UI.Window;

local DEFAULT_STYLE = {
    titleColor = .2,
};

function Window:Constructor(parent, style)
    self.frame = Frames.New(parent);
    self:AddDestructor(Frames.Destroy, self.frame);
    Frames.Backdrop(self.frame, "tooltip");
    Frames.BackdropColor(self.frame, "black");

    self.style = Metatables.StyleClient(style);
    self.style:Inherits(DEFAULT_STYLE);

    self.title = Frames.Color(self.frame, .2);
    Anchors.Clear(self.title);
    Anchors.ShareTop(self.title);
    Frames.Height(self.title, 20);

    self.content = Frames.New(self.frame);
    self:AddDestructor(Frames.Destroy, self.content);
    Anchors.ShareAll(self.content);
    Anchors.VFlip(self.content, self.title, "bottom");

    self.close = Frames.New("Button", self.frame);
    self:AddDestructor(Frames.Destroy, self.close);
    Frames.Size(self.close, 18);
    Anchors.Share(self.close,"topright")
    Frames.ButtonTexture(self.close, "close");
    Callbacks.Click(self.close, Frames.Hide, self);

    self.commands = {};
    self.commandList = UI.List:New();
    self.commandList:SetContent(self.commands);

    self.commandList:SetLayout(function(frames)
        Anchors.ShareVerticals(frames, self.title);
        return Anchors.HJustify("topleft", 2, frames);
    end);
    self.commandList:OnUpdate(Headless(Anchors.Share, self.title, "topleft"));
end;

function Window:AddCommand(description, runner, ...)
    -- TODO Support description objects
    local command = Frames.New(self.frame);
    local text = Frames.Text(command, "friz", 14, "outline");
    command.text = text;
    text:SetText(description);
    Anchors.ShareAll(text);

    local listRemover = Lists.Insert(self.commands, command);
    local clickRemover = Callbacks.Click(command, runner, ...);

    self:Update();

    return Functions.OnlyOnce(function()
        listRemover();
        clickRemover();
    end);
end;

function Window:Update()
    for _, command in ipairs(self.commands) do
        command:SetWidth(command.text:GetStringWidth());
        command:SetHeight(16);
    end;
    self.commandList:Update();
end;

function Window:GetContentFrame()
    return self.content;
end;

function Window:GetTitleFrame()
    return self.title;
end;

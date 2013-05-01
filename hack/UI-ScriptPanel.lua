if nil ~= require then
    require "wow/EditBox";

    require "hack/Script";
    require "fritomod/OOP-Class";
    require "fritomod/Frames";
    require "fritomod/Media-Color";
    require "fritomod/Media-Font";
    require "fritomod/LuaEnvironment";
end;

UI = UI or {};
UI.Hack = UI.Hack or{};

UI.Hack.ScriptPanel = OOP.Class();
local ScriptPanel = UI.Hack.ScriptPanel;

function ScriptPanel:Constructor(parent)
    self.frame = Frames.New(parent);
    self:AddDestructor(Frames.Destroy, self.frame);

    self.environment = LuaEnvironment:New();
    self:AddDestructor(self.environment, "Destroy");

    self.panel = Frames.New(self);
    self.selector = Frames.New(self);
    self:AddDestructor(Frames.Destroy, self.panel, self.selector);

    local panels = {self.selector, self.panel};
    Anchors.ShareVerticals(panels);
    Anchors.Share(self.selector, "left");
    Anchors.Share(self.panel,    "right");
    Anchors.HFlip(self.panel, self.selector, "right", 2);
    self.selector:SetWidth(100);

    self.scriptText = Frames.EditBox(self);
    self:AddDestructor(Frames.Destroy, self.scriptText);
    self.scriptText:SetMultiLine(true);
    Frames.Font(self.scriptText, "consolas", 13);

    Anchors.ShareAll(self.scriptText, self.panel);
end;

function ScriptPanel:Set(script)
    self.script = script;
    self:Update();
end;

function ScriptPanel:Execute()
    if not self.script then
        return;
    end;
    self.script:SetContent(self.scriptText:GetText());
    self.script:Reset();
    return self.script:Execute(self.environment);
end;

function ScriptPanel:Update()
    if self.script then
        self.scriptText:SetText(self.script:GetContent());
    else
        self.scriptText:SetText("");
    end;
end;

-- vim: set et :

Log = FritoLib.OOP.Class();

function print(...)
    local message = tostring(concat(...));
    ChatFrame1:AddMessage(message, 0.0, 0.6, 0.0);
end;

function MixinLog(obj, logAttrName)
    if not logAttrName then
        logAttrName = "log";
    end;
    local objLog = obj[logAttrName];
    obj.Cat = ObjFunc(objLog, "Cat");
    obj.Head = ObjFunc(objLog, "Head");
    obj.Tail = ObjFunc(objLog, "Tail");
end;

function Log.prototype:init(owner, prefix)
    Log.super.prototype.init(self);
    self.owner = owner;
    self.prefix = prefix;
    if self.owner and not self.prefix then
        self.prefix = tostring(self.owner);
    end;
end;

function Log.prototype:SetPrefix(prefix)
    self.prefix = prefix;
end;

function Log.prototype:GetPrefix()
    return self.prefix;
end;

function Log.prototype:Log(...)
    table.insert(self, {...});
    if LoggingManager and self.owner ~= LoggingManager then
        LoggingManager:Log(...);
    end;
end;

function Log.prototype:Print(...)
    local message = tostring(concat(...));
    if self:GetPrefix() then
        message = self:GetPrefix() .. " - " .. message;
    end;
    print(message);
end;

function Log.prototype:Cat()
    for _, message in ipairs(self) do
        self:Print(unpack(message));
    end;
end;

function Log.prototype:Head(numShown)
    if not numShown then
        numShown = 10;
    end;
    numShown = min(numShown, #self);
    for i=1, numShown do
        self:Print(unpack(self[i]));
    end;
end;

function Log.prototype:Tail(numShown)
    if not numShown then
        numShown = 10;
    end;
    local start = max(1, #self - numShown);
    numShown = min(numShown, #self);
    for i=start,numShown do
        self:Print(unpack(self[i]));
    end;
end;


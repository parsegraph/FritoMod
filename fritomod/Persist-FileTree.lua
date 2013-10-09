if nil ~= require then
    require "fritomod/currying";
    require "fritomod/OOP-Class";
    -- Rainback is also required
end;

Persist = Persist or {};

Persist.FileTree = OOP.Class("Persist.FileTree");

function Persist.FileTree:Constructor(path)
    self.path = path;
end;

function Persist.FileTree:SetNameWriter(nameWriter, ...)
    self.nameWriter = Curry(nameWriter, ...);
end;

function Persist.FileTree:SetNameReader(nameReader, ...)
    self.nameReader = Curry(nameReader, ...);
end;

function Persist.FileTree:SetWriter(writer, ...)
    self.writer = Curry(writer, ...);
end;

function Persist.FileTree:SetReader(reader, ...)
    self.reader = Curry(reader, ...);
end;

function Persist.FileTree:Load()
    if not Rainback.FileExists(self.path) then
        print("No file exists for path: " .. self.path);
        return;
    end;
    local data = {};
    for _, name in pairs(Rainback.ListFiles(self.path)) do
        local serialized = Rainback.ReadFile(self.path .. "/" .. name);
        local readData = self.reader(serialized, name);
        if readData ~= nil then
            local id = self.nameReader(readData, name);
            if id then
                data[id] = readData;
            else
                table.insert(data, readData);
            end;
        end;
    end;
    return data;
end;

function Persist.FileTree:Save(data)
    local created = false;
    for k, v in pairs(data) do
        if not created then
            Rainback.CreateDirectory(self.path);
            created = true;
        end;
        local name = self.nameWriter(v, k);
        local serialized = self.writer(v, k);
        Rainback.WriteFile(self.path .. "/" .. name, serialized);
    end;
end;

Convention = {};
local Convention = Convention;

function Convention:InsertRegisteredMapping(class, properMapName, nameRetrieverFunc, ...)
    nameRetrieverFunc = ObjFunc(nameRetrieverFunc, ...);
    local tableName = StringUtil:ProperToCamelCase(properMapName) .. "Map";

    class.__AddConstructor(function(self)
        self[tableName] = {};
    end);

    class["Get" .. properMapName] = function(self, name)
        return self[tableName][name];
    end;

    class["Register" .. properMapName] = function(self, mappedValue)
        local name = nameRetrieverFunc(mappedValue);
        local incumbentValue = self["Get" .. properMapName](self, name);
        -- This function fails if a value already exists for the name unless that 
        -- value is equal to the given value.
        if incumbentValue and incumbentValue ~= mappedValue then
            error("Cannot overwrite this value of name: " .. name);
        end;
        self[tableName][name] = mappedValue;
        return function()
            if self[tableName][name] == mappedValue then
                self[tableName][name] = nil;
            end;
        end;
    end;
end;

function Convention:InsertListenerShortcut(class, shortcutName, eventName)
    class["Add" .. shortcutName] = function(self, listenerFunc, ...)
        return self:AddListener(eventName, listenerFunc, ...);
    end;
end;

function Convention:InsertGetter(class, variableName)
    class["Get" .. StringUtil:ProperToCamelCase(variableName)] = function(self)
        return self[variableName];
    end;
end;

function Convention:InsertSetter(class, variableName)
    class["Set" .. StringUtil:ProperToCamelCase(variableName)] = function(self, value)
        self[variableName] = value;
    end;
end;

function Convention:InsertAccessor(class, variableName, accessorName)
    Convention:InsertGetter(class, variableName, accessorName);
    Convention:InsertSetter(class, variableName, accessorName);
end;

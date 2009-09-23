Conventions = {};
local Conventions = Conventions;

-- TODO: What does this method do? Where is it used?
function Conventions:InsertRegisteredMapping(class, properMapName, nameRetrieverFunc, ...)
    nameRetrieverFunc = Curry(nameRetrieverFunc, ...);
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

function Conventions:InsertListenerShortcut(class, shortcutName, eventName)
    class["Add" .. shortcutName] = function(self, listenerFunc, ...)
        return self:AddListener(eventName, listenerFunc, ...);
    end;
end;

function Conventions:InsertGetter(class, variableName)
    class["Get" .. StringUtil:CamelToProperCase(variableName)] = function(self)
        return self[variableName];
    end;
end;

function Conventions:InsertSetter(class, variableName)
    class["Set" .. StringUtil:CamelToProperCase(variableName)] = function(self, value)
        self[variableName] = value;
    end;
end;

function Conventions:InsertObservedSetter(class, variableName, observerFunc, ...)
    observerFunc = ObjFunc(observerFunc, ...);
    class.__AddConstructor(function(self)
        local sanitizer;
        self["Set" .. StringUtil:CamelToProperCase(variableName)] = function(self, value)
            if self[variableName] == value then
                return;
            end;
            if self[variableName] ~= nil and sanitizer then
                sanitizer();
            end;
            self[variableName] = value;
            sanitizer = observerFunc(value, self);
        end;
    end);
end;

function Conventions:InsertGuardedSetter(class, variableName, guardFunc, ...)
    guardFunc = ObjFunc(guardFunc, ...);
    class["Set" .. StringUtil:CamelToProperCase(variableName)] = function(self, value)
        if self[variableName] == value then
            return;
        end;
        self[variableName] = guardFunc(value, self);
    end;
end;

function Conventions:InsertDefaultGetter(class, variableName, defaultValue)
    class["Get" .. StringUtil:CamelToProperCase(variableName)] = function(self)
        if self[variableName] ~= nil then
            return self[variableName];
        end;
        return defaultValue;
    end;
end;

function Conventions:InsertAccessor(class, variableName)
    Conventions:InsertGetter(class, variableName);
    Conventions:InsertSetter(class, variableName);
end;

function Conventions:InsertObservedAccessor(class, variableName, observerFunc, ...)
    Conventions:InsertGetter(class, variableName);
    Conventions:InsertGuardedSetter(class, variableName, observerFunc, ...);
end;

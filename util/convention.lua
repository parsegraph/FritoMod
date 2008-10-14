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

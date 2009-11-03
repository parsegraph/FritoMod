if Mixins == nil then
    Mixins = {};
end;

-- Adds an operation for keys and values to the specified library. The operation
-- is given the appropriate iterator function for the item type.
--
-- library
--     the library that is the target of this mixin
-- name
--     the name format. "Key", or "Value" will be interpolated
-- operation
--     the function that is mixed in. It should expect a iterator function for its first argument
function Mixins.KeyValueOperation(library, name, operation)
    if library[name:format("Key")] == nil then
        library[name:format("Key")] = Curry(operation, library.KeyIterator);
    end;
    if library[name:format("Value")] == nil then
        library[name:format("Value")] = Curry(operation, library.ValueIterator);
    end;
end;

-- Adds an operation for keys, values, and pairs to the specified library. The operation
-- is given a chooser function that selects the appropriate item for the item type.
--
-- library
--     the library that is the target of this mixin
-- name
--     the name format. "Pair", "Key", or "Value" will be interpolated
-- operation
--     the function that is mixed in. It should expect a chooser function for the first argument.
--     The chooser has the signature chooser(key, value) and returns the appropriate item for
--     the item type.
function Mixins.KeyValuePairOperation(library, name, operation)
    if library[name:format("Pair")] == nil then
        library[name:format("Pair")] = Curry(operation, function(key, value)
            return key, value;
        end);
    end;
    if library[name:format("Key")] == nil then
        library[name:format("Key")] = Curry(operation, function(key, value)
            return key;
        end);
    end;
    if library[name:format("Value")] == nil then
        library[name:format("Value")] = Curry(operation, function(key, value)
            return value;
        end);
    end;
end;

-- Adds an operation for keys, values, and pairs to the specified library.
--
-- library
--     the library that is the target of this mixin
-- name
--     the name format. "Pair", "Key", or "Value" will be interpolated
-- operation
--     the function that is mixed in. It should expect the item type as the first
--     argument.
function Mixins.KeyValuePairOperationByName(library, name, operation)
    if library[name:format("Pair")] == nil then
        library[name:format("Pair")] = Curry(operation, "Pair");
    end;
    if library[name:format("Key")] == nil then
        library[name:format("Key")] = Curry(operation, "Key");
    end;
    if library[name:format("Value")] == nil then
        library[name:format("Value")] = Curry(operation, "Value");
    end;
end;


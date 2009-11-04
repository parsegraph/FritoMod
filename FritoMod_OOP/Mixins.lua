if nil ~= require then
    require "FritoMod_Functional/currying";

    require "FritoMod_OOP/OOP";
end;

if Mixins == nil then
    Mixins = {};
end;
local Mixins = Mixins;

-- Transforms the specified table into a mixin. When the class is initialized, 
-- all methods on the library are added to the initializing class.
-- 
-- library
--     Optional. A table that is the source of the mixed-in functions. If
--     nil, then a empty table is used. You may omit this entirely, and just
--     provide a constructorFunc as the first argument, like so:
--     Mixins.Library(constructorFunc, "stuff", "otherStuff");
-- constructorFunc
--     Optional. A method that acts as the constructor for this mixin.
-- returns
--     library
Mixins.Library = function(library, constructorFunc, ...)
    if library and type(library) ~= "table" then
        constructorFunc = Curry(library, constructorFunc, ...);
        library = {};
    elseif constructorFunc or select("#", ...) > 0 then
        library = library or {};
        constructorFunc = Curry(constructorFunc);
    else
        library = library or {};
    end;
    setmetatable(library, {
        __call = function(library, class) 
            OOP.IntegrateLibrary(library, class);
            return constructorFunc;
        end;
    });
    return library;
end;

-- A mixin that guarantees a class can only be instantiated once. This
-- ensures that the class may only be instantiated through calls to
-- GetInstance.
--
-- class
--     The class that is the target of this mixin.
-- throws
--     if class is falsy
-- returns
--     a constructor for this mixin. The returned constructor throws an
--     error if more than one instance is attempting to be created.
Mixins.Singleton = function(class)
    if not class then
        error("Class is falsy");
    end;
    local instance = nil;
    class.GetInstance = function()
        if not instance then
            instance = class:New();
        end;
        return instance;
    end;
    return function()
        if instance then
            error("Singletons can only be instantiated once.");
        end;
    end;
end;

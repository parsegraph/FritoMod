--[[
FritoMod's inheritance:
 - Single-inheritance (duck-typed)
--]]

OOP = {};
local OOP = OOP;

OOP.Class = function(parentClass, ...)
    local initializers = { ... };
    if parentClass and (type(parentClass) ~= "table" or not rawget(parentClass, "__init")) then
        table.insert(initializers, 1, parentClass);
    end;
    local class = nil;
    class = {
        __uninitialized = true,
        __unfinalized = true,
        __initialize = function()
            class.__uninitialized = nil;
            for _, initializer in ipairs(class.__initializers) do
                if not IsCallable(initializer) then
                    error("Not callable: " .. tostring(initializer));
                end;
                local constructor = initializer(class);
                if constructor then
                    class.__AddConstructor(constructor);
                end;
            end;
            class.__initialize = nil;
            class.__initializers = nil;
            class.__unfinalized = nil;
        end,
        __initializers = initializers, 
        __AddInitializer = function(initializerFunc, ...)
            if not class.__uninitialized then
                error("Class has already been initialized, so no more initializers can be added.");
            end;
            class.__initializers = class.__initializers or {};
            initializerFunc = ObjFunc(initializerFunc, ...);
            table.insert(class.__initializers, initializerFunc);
            return initializerFunc;
        end,
        __AddConstructor = function(constructorFunc, ...)
            if not class.__unfinalized then
                error("Class has already been initialized, so no more constructors can be added.");
            end;
            class.__constructors = class.__constructors or {};
            constructorFunc = ObjFunc(constructorFunc, ...);
            table.insert(class.__constructors, constructorFunc);
            return constructorFunc;
        end,
        __super = parentClass,
        __init = function(self)
            -- noop
        end,
        __index = function(self, key)
            local value = rawget(class, key);
            if value == nil and parentClass then
                return parentClass[key];
            end;
            return value;
        end,
    };
    local inheritanceMetatable = {
        __index = function(self, key)
            local class = rawget(self, "__class");
            local value = nil;
            while true do
                value = class[key];
                if value ~= nil then
                    return value;
                elseif not class.__super then
                    return;
                else
                    class = class.__super;
                end;
            end;
        end
    };
    setmetatable(class, {
        __call = function(class, ...)
            if rawget(class, "__uninitialized") then
                class.__initialize();
            end;
            class.__unfinalized = nil;
            local object = setmetatable({ __class = class }, inheritanceMetatable);
            function Initialize(class)
                if class.__super then
                    Initialize(class.__super);
                end;
                if class.__constructors then
                    for _, constructor in ipairs(class.__constructors) do
                        constructor(object, class);
                    end;
                end;
            end;
            Initialize(class);
            if class.__init then
                class.__init(object, ...);
            end;
            return object;
        end,
        __index = function(self, key)
            if rawget(class, "__uninitialized") then
                rawget(class, "__initialize")();
            end;
            return rawget(class, key);
        end,
    });
    return class;
end;

OOP.MixinLibrary = function(constructorFunc, library)
    library = library or {};
    return OOP.Mixin(
        ObjFunc(OOP.IntegrateLibrary, library),
        constructorFunc,
        library
    );
end;

OOP.Mixin = function(initializerFunc, constructorFunc, library)
    library = library or {};
    setmetatable(library, { __call = function(self, class)
        initializerFunc(class);
        return constructorFunc;
    end });
    return library;
end;

OOP.IntegrateLibrary = function(library, class, c)
    for funcName, func in pairs(library) do
        if string.match(funcName, "__") ~= 1 then
            class[funcName] = func;
        end;
    end
end

OOP.Singleton = function(class)
    local instance = nil;
    class.GetInstance = function()
        if not instance then
            instance = class();
        end;
        return instance;
    end;
    return function()
        if instance then
            error("Singletons can only be instantiated once.");
        end;
    end;
end;

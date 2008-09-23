--[[
FritoMod's inheritance:
 - Single-inheritance (duck-typed)
 - Inheritance chain exposed through self.__super, self.__class
--]]

OOP = {};
local OOP = OOP;

OOP.Class = function(parentClass, ...)
    local class = {
        __uninitialized = true,
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
            if not class.__uninitialized then
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
        end;
    };
    setmetatable(class, {
        __call = function(...)
            local object = { __class = class, __super = parentClass };
            setmetatable(object, class);
            function Initialize(class)
                if class.__super then
                    Initialize(class.__super);
                end;
                if class.__uninitialized then
                    class.__uninitialized = nil;
                    for _, initializer in ipairs(class.__initializers) do
                        local constructor = initialize(class);
                        if constructor then
                            class.__AddConstructor(constructor);
                        end;
                    end;
                    class.__initializers = nil;
                end;
                if class.__constructors then
                    for _, constructor in ipairs(class.__constructors) do
                        constructor(object, class);
                    end;
                end;
            end;
            Initialize(class);
            if class.__init then
                class.__init(object);
            end;
            return object;
        end
    });
    if parentClass then
        setmetatable(class, { __index = parentClass });
    end;
    return class;
end;

OOP.MixinLibrary = function(constructorFunc, library)
    return Mixin(
        ObjFunc(OOP.IntegrateLibrary, library),
        constructorFunc,
        library
    );
end;

OOP.Mixin = function(initializerFunc, constructorFunc, library)
    library = library or {};
    setmetatable(library, { __call, function(class)
        if initializerFunc then
            class.__AddInitializer(initializerFunc);
        end;
        if constructorFunc then
            class.__AddConstructor(constructorFunc);
        end;
    end });
    return library;
end;

OOP.IntegrateLibrary = function(library, class)
    for funcName, func in pairs(library) do
        if string.match(funcName, "__") ~= 1 then
            class[funcName] = func;
        end;
    end
end

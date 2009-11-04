local SUPER_NAME = "super";
local CLASS_NAME = "class";
local CONSTRUCTOR_NAME = "Constructor";

local CLASS_METATABLE = {
    GetMethodIterator = function(self) 
    end,

    -- A default constructor. This is called after all constructors are used, 
    -- and will only be called on the immediate class that's being created; 
    -- it is each constructor's responsibility to either call their parent's 
    -- constructor, or perform any action that the parent constructor is tasked 
    -- to do.
    --
    -- This should be overridden in most cases by whatever construction you wish 
    -- to do, and the signature used here does not need to be preserved. Any 
    -- return value is ignored.
    Constructor = function(self)
        -- noop
    end,


    -- Calls all constructors on the specified object.
    --
    -- object
    --     the object that is constructed
    -- throws
    --     if object is falsy
    ConstructObject = function(self, object)
        if not object then
            error("Object is falsy");
        end;
        for i=1, #self.constructors do
            local constructor = self.constructors[i];
            constructor(object);
        end;
    end,

    -- Add a mixin to this class. A mixin is a callable should expect the signature
    -- mixinFunc(class). A mixin is expected to add some functionality to a class.
    --
    -- mixinFunc
    --     The function that performs the work of the mixin. It is called immediately.
    --
    --     If the mixinFunc returns a callable, then that callable will be invoked
    --     for every instance of the class. It should expect the signature 
    --     "callable(object)"
    -- ...
    --     any arguments that are curried to mixinFunc
    AddMixin = function(self, mixinFunc, ...)
        mixinFunc = Curry(mixinFunc, ...);
        local constructor = mixinFunc(self);
        if constructor then
            self:AddConstructor(constructor);
        end;
    end,

    -- Adds the specified constructor function to this class. The constructor will be called
    -- for all created instances of this class, but before the instance's actual constructor
    -- is invoked.
    AddConstructor = function(self, constructorFunc, ...)
        constructorFunc = Curry(constructorFunc, ...);
        self.constructors = self.constructors or {};
        table.insert(self.constructors, constructorFunc);
    end,

    ToString = function(self)
        local reference = Reference(self);
        if self[CLASS_NAME] then
            return "Instance@" .. reference;
        end;
        return "Class@" .. reference;
    end,

    -- Creates a new instance of this class.
    New = function(self, ...)
        local instance = { 
            __index = self,
            __tostring = function(self)
                return self:ToString()
            end
        };
        instance[CLASS_NAME] = self;
        setmetatable(instance, instance);

        local function Initialize(class)
            if class[SUPER_NAME] then
                Initialize(class[SUPER_NAME]);
            end;
            class:ConstructObject(instance);
        end;
        Initialize(self);

        instance:Constructor(...);
        return instance;
    end
}

-- Creates a callable table that creates instances of itself when invoked. This is analogous
-- to classes: a super-class may be provided in the arguments, and that class will act as the
-- default source of methods for the returned class.
--
-- You may also provide other functions in the arguments. These functions act as mixins, and are
-- allowed to add functionality to this class. If they return a callable, that callable will be
-- invoked on every instance of this class.
--
-- ...
--     Any mixins, and up to one super class, that should be integrated into this class.
-- throws
--     if any provided argument is not either a mixin or a class
--     if more than one super-class is provided (multiple inheritance in this manner is not supported)
OOP.Class = function(...)
    local class = { constructors = {}};
    class.__index = CLASS_METATABLE;
    setmetatable(class, class);

    for n = 1, select('#', ...) do
        local mixinOrClass = select(n, ...);
        if not mixinOrClass then
            error("Mixin or class is falsy. Index " .. n);
        end;
        if OOP.IsClass(mixinOrClass) then
            --  It's a class, so make it our super class.
            if class[SUPER_NAME] then
                error("Class cannot have more than one super class");
            end;
            class[SUPER_NAME] = mixinOrClass;
            class.__index = class[SUPER_NAME];
        elseif IsCallable(mixinOrClass) then
            local constructor = mixinOrClass(class);
            if IsCallable(constructor) then
                class:AddConstructor(constructor);
            end;
        else
            error(("Object is not a mixin or super-class: %s"):format(tostring(mixinOrClass)));
        end;
    end

    return class;
end;

OOP = {};
local OOP = OOP;

-- This metatable implements classical inheritance by iterating up the class's __super attribute. Notice that
-- since nil values are equivalent to non-existent values, they indicate that the parent's value should be
-- used instead. In short, use false if you wish to have a falsy value that masks the parent's.
--
-- This is assigned as a metatable to every instance that is created.
OOP.INHERITANCE_METATABLE = {
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

-- Creates a callable table that creates instances of itself, integrating any given mixins and
-- the optional parentClass on creation.
OOP.Class = function(parentClass, ...)
    local initializers = { ... };
    if parentClass and (type(parentClass) ~= "table" or not rawget(parentClass, "__Init")) then
        table.insert(initializers, 1, parentClass);
    end;

    local class = nil;
    class = {

        -----------------------------------------------------------------------
        --
        --  Public Overrides and Interface
        --
        -----------------------------------------------------------------------

        -- A default constructor. This is called after all constructors are used, and will only be called on the immediate class
        -- that's being created; it is each constructor's responsibility to either call their parent's constructor, or perform
        -- any action that the parent constructor is tasked to do.
        --
        -- This should be overridden in most cases by whatever construction you wish to do, and the signature used here does not
        -- need to be preserved. Any return value is ignored.
        __Init = function(self)
            -- noop
        end,

        -- A safe reference to the parentClass. You should use this instead of getmetatable since that exposes implementation
        -- details of our inheritance.
        --
        -- class.__super.__super.__super will return the great-grandparent of that class.
        __super = parentClass,

        -----------------------------------------------------------------------
        --
        --  Advanced Public Interface
        --
        -----------------------------------------------------------------------

        -- Add an initializer to this class. These are called immediately before this class is used or accessed.
        -- An initializer should expect the signature initializer(class), where the class's state may be temporarily
        -- unusable, so every effort should be made for an initializer to not use the class when it is initialized.
        --  
        -- This function will throw if it is called anytime past the start of initialization.
        __AddInitializer = function(initializerFunc, ...)
            if not class.__uninitialized then
                error("Class has already been initialized, so no more initializers can be added.");
            end;
            class.__initializers = class.__initializers or {};
            initializerFunc = ObjFunc(initializerFunc, ...);
            table.insert(class.__initializers, initializerFunc);
            return initializerFunc;
        end,

        -- Add a constructor to this class. These are called before __Init's are called on the instance. They should
        -- expect the signature constructor(instance).
        --  
        -- This function will throw if it is called after the class has been initialized. It is safe to use during
        -- initialization.
        __AddConstructor = function(constructorFunc, ...)
            if not class.__unfinalized then
                error("Class has already been finalized, so no more constructors can be added.");
            end;
            class.__constructors = class.__constructors or {};
            constructorFunc = ObjFunc(constructorFunc, ...);
            table.insert(class.__constructors, constructorFunc);
            return constructorFunc;
        end,

        -- Calls all initializers added either on the OOP.Class call, or separately through __AddInitializer.
        --
        -- This function is idempotent, and will return silently and perform no action if the class is already
        -- initialized.
        --
        -- You should never need to call this function - it is called whenever the class's attributes are accessed
        -- or when the class is used to construct a new instance. You may safely call this function at any time.
        __Initialize = function()
            if not class.__uninitialized then
                -- Be idempotent.
                return;
            end;
            class.__uninitialized = nil;
            
            for _, initializer in ipairs(class.__initializers) do
                if not IsCallable(initializer) then
                    error("Not callable: " .. tostring(initializer));
                end;
                -- Any callable values returned from an initializer are added as constructors.
                local constructor = initializer(class);
                if constructor and IsCallable(constructor) then
                    class.__AddConstructor(constructor);
                end;
            end;
            
            class.__initializers = nil;
            class.__unfinalized = nil;
        end,

        -----------------------------------------------------------------------
        --
        --  Internals
        --
        -----------------------------------------------------------------------

        -- Uninitialized is true until initializers are used on this class. That occurs either when
        -- this class, or a subclass of it, is constructed, or _any_ value on this class is accessed.
        --  
        -- __Initialize sets this value falsy when it is first called, NOT when it is completed. Once
        -- this value is falsy, __AddInitializer will throw if used and calls to __Initialize will return
        -- immediately.
        __uninitialized = true,

        -- Unfinalized is true until all initializers have been fired. This occurs at the end of a
        -- call to __Initialize. Once this value is falsy, __AddConstructor will throw if used. It is
        -- guaranteed that if this is false, then __uninitialized is also false.
        __unfinalized = true,

        -- Internal list of initializers. You should _never_ assume this exists or attempt to use it directly.
        -- Initializers are only added through __AddInitializer, and are not allowed to be removed once added.
        __initializers = initializers, 
    };

    setmetatable(class, {

        -- When the class is called, a new instance is created. The process occurs in this order:
        --
        -- 1. Create the instance, assigning the metatable to it to implement classical inheritance.
        -- 2. Iterate through the inheritance chain, starting with the deepest ancestor, and:
        --  a. Initialize it if necessary.
        --  b. Call all constructors on it using our new instance.
        -- 3. Once every constructor has been called, call the class's __Init using our new object and
        --    any arguments given with the initial call.
        -- 4. Return the fully constructed object.
        __call = function(class, ...)
            local object = setmetatable({ __class = class }, OOP.INHERITANCE_METATABLE);
            function Initialize(class)
                if class.__super then
                    Initialize(class.__super);
                end;
                if class.__uninitialized then
                    class.__Initialize();
                end;
                if class.__constructors then
                    for _, constructor in ipairs(class.__constructors) do
                        constructor(object);
                    end;
                end;
            end;
            Initialize(class);
            if class.__Init then
                class.__Init(object, ...);
            end;
            return object;
        end,

        -- This metamethod ensures that initialization occurs before any non-internal methods or attributes used.
        __index = function(self, key)
            -- Notice that we explicitly avoid initialization if the key name requested begins with double underscores.
            if rawget(class, "__uninitialized") and (type(key) ~= "string" or not string.find(key, "^__")) then
                class.__Initialize();
            end;
            return rawget(class, key);
        end,
    });
    return class;
end;

-----------------------------------------------------------------------
--
--  API Functions
--
-----------------------------------------------------------------------

-- Integrates a library into a given class.
OOP.IntegrateLibrary = function(library, class)
    for funcName, func in pairs(library) do
        if not string.match(funcName, "^__") then
            class[funcName] = func;
        end;
    end
end

-----------------------------------------------------------------------
--
--  Preconstructed mixins
--
-----------------------------------------------------------------------

-- Create a MixinLibrary using the given table and optional constructorFunc.
OOP.MixinLibrary = function(constructorFunc, library)
    if type(constructorFunc) == "table" and not IsCallable(constructorFunc) then
        library = constructorFunc;
        constructorFunc = nil;
    end;
    library = library or {};
    return setmetatable(library, {
        __call = function(library, class) 
            OOP.IntegrateLibrary(library, class);
            return constructorFunc;
        end;
    });
end;

-- Guarantees a Singleton.
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


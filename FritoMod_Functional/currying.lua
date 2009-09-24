-- Methods that provide currying, a common functional programming idiom that allows one
-- to partially apply a method.

-- Curries the specified method or function using any specified arguments. This will make
-- a best-effort approach to determine what method to invoke.
--
-- objOrFunc must not be a callable table. Such things are too ambiguous to be reliably
-- coerced into a method or function, so we just disallow them outright. Use CurryMethod or
-- CurryFunction to get the behavior you need.
--
-- objOrFunc
--     Either:
--     a. A reference to a function. CurryFunction will be used.
--     b. A non-callable table. CurryMethod will be used.
--     c. A string that is the name of a method. CurryHeadlessMethod will be used.
-- funcOrName
--     If objOrFunc is a table, then this is a string referring to a method, or a method 
--     reference.
--     If objOrfunc is a function, then this is simply the first argument.
-- ...
--     arguments that are curried to the method or function
-- returns
--     a callable that, when invoked, will call the specified method or function.
-- throws
--     if objOrFunc is a callable table, falsy, or is not a string, table, or function.
function Curry(objOrFunc, funcOrName, ...)
    if not objOrFunc then
        error("objOrFunc is falsy");
    end;
    if type(objOrFunc) == "function" then 
        return CurryFunction(objOrFunc, funcOrName, ...);
    end;
    if type(objOrFunc) == "table" then 
        local metatable = getmetatable(objOrFunc);
        if metatable and IsCallable(getmetatable(objOrFunc).__call) then
            -- Callable tables are too ambiguous to be implicitly curried. If you need to curry
            -- a callable table, use the CurryMethod or CurryFunction methods.
            error("objOrFunc is a callable table and therefore ambiguous.");
        end;
        return CurryMethod(objOrFunc, funcOrName, ...);
    end;
    if type(objOrFunc) == "string" then
        return CurryHeadlessMethod(objOrFunc, funcOrName, ...);
    end;
    error("objOrFunc is not a string, table, or function. Received type: " .. type(objOrFunc));
end;

-- Curries the specified function using any specified arguments, returning a callable
-- that represents the curried function.
--
-- For example, all examples are equivalent:
-- a.) Naive call
-- foo(a, b, c, d)
-- 
-- b.) Curried call
-- curried = CurryFunction(foo, a, b)
-- curried(c, d) -- invokes foo(a, b, c, d)
--
-- func
--     A callable that is curried
-- ...
--     Any arguments that should be passed, in order, before subsequent arguments, to 
--     func. These are optional.
-- returns
--     A callable that, when invoked, invokes func with the specified arguments.
function CurryFunction(func, ...)
    if not func then
        error("func is falsy");
    end;
    if not IsCallable(func) then
        error("func is not a function or string. Received type: %s", func);
    end;
    if select("#", ...) == 0 then
        return func;
    end;
    local args = {...};
    return function(...)
        return func(UnpackAll(args, {...}));
    end;
end

-- Curries the specified method using the specified arguments, returning a callable that
-- represents the curried method. This method allows func to be a reference or a string that
-- represents a method name.
--
-- For example, all examples are equivalent:
-- a.) Naive call
-- obj:foo(a, b, c, d);
--
-- b.) Reference-based method currying
-- curried = CurryMethod(obj, foo, a, b);
-- curried(c, d);
--
-- c.) String-based method currying
-- curried = CurryMethod(obj, "foo", a, b);
-- curried(c, d);
--
-- object
--     The object that contains the curried method.
-- func
--     A reference to a method, or a string representing the name of the method, that is curried.
-- ...
--     Any arguments that should be passed, in order, before subsequent arguments, to 
--     func. These are optional.
-- returns
--     A callable that invokes the curried method, passing along subsequent arguments.
function CurryMethod(object, func, ...)
    if not object then
        error("object is falsy");
    end;
    if not func then
        error("func is falsy");
    end;
    if type(object) ~= "table" then
        error(format("object is not a table. Received type: %s", type(object)));
    end;
    local args = { ... };
    if IsCallable(func) then
        return function(...)
            return func(object, UnpackAll(args, {...}));
        end;
    elseif type(func) == "string" then
        return function(...)
            local callable = object[func];
            assert(callable, "Callable is false. Name: " .. func);
            return callable(object, UnpackAll(args, {...}));
        end;
    end;
    error("func is not callable and is not a string. Received type: " .. type(func));
end

-- Curries the specified headless method using the specified arguments, returning a callable 
-- that represents the curried headless method. On invocation, the returned callable will use 
-- the first argument as the "self" for the headless method.
--
-- This is useful for times where you want a method to be called on a group of objects. Many methods
-- in utility methods use this method for that purpose.
--
-- a.) Reference-based method currying
-- curried = CurryHeadlessMethod(foo, a, b);
-- curried(obj, c, d); -- invokes foo(obj, a, b, c, d);
--
-- b.) String-based method currying
-- curried = CurryHeadlessMethod("foo", a, b);
-- curried(obj, c, d); -- invokes foo(obj, a, b, c, d);
--
-- func
--     A reference to a method, or a string representing the name of the method, that is curried.
-- ...
--     Any arguments that should be passed, in order, before subsequent arguments, to 
--     func. These are optional.
-- returns
--     A callable that invokes the curried method, passing along subsequent arguments.
function CurryHeadlessMethod(func, ...)
    if not func then
        error("func is falsy");
    end;
    local args = {...};
    if IsCallable(func) then
        return function(self, ...)
            if not self then
                error("self is falsy");
            end;
            return func(self, UnpackAll(args, {...}));
        end;
    elseif type(func) == "string" then
        return function(self, ...)
            if not self then
                error("self is falsy");
            end;
            return self[func](self, UnpackAll(args, {...}));
        end;
    end;
    error("func is not callable and is not a string. Received type: %s", type(func));
end

-- Returns a method that ignores any arguments passed to it, only invoking the specified
-- function with its curried arguments. In effect, this creates a sealed function that is
-- fully applied. Sealed functions are useful when you wish to use a fully applied function
-- in a situation where arguments may be unnecessarily passed to it.
--
-- func(a, b); -- Calls func(a, b)
-- curried = Seal(func, a, b);
-- curried(); -- Calls func(a, b)
-- curried(c, d); -- Still calls func(a, b)
--
-- func
--     the function that will be sealed by this method
-- ...
--      any arguments that will be passed to func when the returned, sealed function is invoked
-- returns
--      a function that will invoke func(...), ignoring any immediate arguments passed to it.
-- throws
--      if func is not callable
function Seal(func, ...)
    func = Curry(func, ...);
    return function()
        return func();
    end;
end;

-- Returns a function that calls the specified function. The returned function guarantees that
-- the specified self argument is always used as the self argument for the function. If one is
-- provided, it is ignored.
--
-- self
--     the self argument that is guaranteed to be the self argument for the specified function
-- func, ...
--     the function that is invoked by the returned function
-- returns
--     a function that behaves as described above
-- throws
--     if self is falsy or not a table
-- see
--     ForcedFunction
function ForcedMethod(self, func, ...)
    assert(self, "self is falsy");
    assert(type(self) == "table", "self is not a table. Type: " .. type(self));
    func = CurryMethod(self, func, ...);
    return function(maybeSelf, ...)
        if maybeSelf == self then
            return func(...);
        end;
        -- It's just another argument, so include it.
        return func(maybeSelf, ...);
    end;
end;

-- Returns a function that calls the specified function. The returned function guarantees that
-- the specified self argument is never used as the self argument for the function. If one is
-- provided, it is omitted.
--
-- self
--     the self argument that is ignored
-- func, ...
--     the function that is invoked by the returned function
-- returns
--     a function that behaves as described above
-- throws
--     if self is falsy or not a table
-- see
--     ForcedMethod
function ForcedFunction(self, func, ...)
    assert(self, "self is falsy");
    assert(type(self) == "table", "self is not a table. Type: " .. type(self));
    func = Curry(func, ...);
    return function(maybeSelf, ...)
        if maybeSelf == self then
            return func(...);
        end;
        -- It's just another argument, so include it.
        return func(maybeSelf, ...);
    end;
end;

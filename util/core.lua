
-------------------------------------------------------------------------------
--
--  Fundamental Methods
--
-------------------------------------------------------------------------------

------------------------------------------
--  Bool
------------------------------------------
--
-- Very naively converts a value to a boolean.
function Bool(value)
	return not not value;
end	

------------------------------------------
--  IsCallable
------------------------------------------
--
-- Returns whether the given value is callable.
function IsCallable(value)
    local valueType = type(value);
    return valueType == "function" or (valueType == "table" and IsCallable(getmetatable(value).__call));
end;

------------------------------------------
--  MakeEqualityComparator
------------------------------------------
--
-- ObjFuncs a comparatorFunc, or returns Operator.Equals.
function MakeEqualityComparator(comparatorFunc, ...)
    if not comparatorFunc then
        return Operator.Equals;
    end;
    return ObjFunc(comparatorFunc, ...);
end;

-------------------------------------------------------------------------------
--
--  Functional Utility Methods
--
-------------------------------------------------------------------------------

------------------------------------------
--  UnpackAll
------------------------------------------
--
-- Given a series of tables, return an unpacked, single table of those values.
--
-- For example:
-- local a, b, c, d = UnpackAll({1,2}, {3}, {4, 5});
-- assert(a == 1 and b == 2 and c == 3 and d == 4);
function UnpackAll( ... )
    local collectedValues = {}
    -- Collect values from all tables.
    for i=1, select('#', ...) do
        local table = select(i, ...);
        for _, value in ipairs(table) do
            table.insert(collectedValues, value);
        end
    end
    return unpack(collectedValues);
end

-- Used in ObjFunc.
local EMPTY_ARGS = {}

-------------------------------------------------------------------------------
--
--  ObjFunc
--
-------------------------------------------------------------------------------
--
-- Given a function "signature", return a function that will call that signature
-- with any additional arguments. Some languages refer to this as a partially-
-- applied function. This framework uses this extensively to provided open-ended
-- and very natural behavior when using functions.
--
-- We use this terminology:
--
-- Partial - The function that this method returns. It comes from the fact that
-- this function acts as though it's been partially applied, but has not yet been
-- truly called.
--
-- Saved Arguments - Arguments passed into ObjFunc, rather than the called Partial.
-- These are always passed first to the Partial, then any additional arguments are
-- included. In code examples, this is savedArgs.
-- 
-- ... - In the examples, this is arguments passed when calling the partial.
--
-- There are three patterns this method accepts, in order of precedence:
--
-- Direct function call - objOrFunc(UnpackAll(savedArgs, {...}))
-- objOrFunc is called directly. funcOrName is just another argument. This is useful
-- when you're just interested in partially applying some arguments.
--
-- Reference-based method call - objOrFunc:funcOrName(UnpackAll(savedArgs, {...}))
-- objOrFunc is the object, and funcOrName is a function that is a method of objOrFunc.
-- This is whenever you want to partially apply a method. 
--
-- Be aware that direct function calls override this pattern, so if your objOrFunc is 
-- callable, it will be interpreted as a direct function call and NOT this pattern. If
-- you run into this, you must use the direct function call pattern and manually pass
-- the object as the first argument.
--
-- Name-based method call - objOrFunc[funcOrName](objOrFunc, UnpackAll(savedArgs, {...}))
-- objOrFunc is the object, and funcOrName is the name of the function that is callable
-- on objOrFunc. This is useful when you don't wish to bind the function to this objFunc,
-- so always use this pattern if you expect the function that objOrFunc[funcOrName] refers
-- to to change.
function ObjFunc(objOrFunc, funcOrName, ...)
    local numArgs = select("#", ...);
    if objOrFunc and funcOrName == nil and numArgs == 0 then
        --rawdebug("ObjFunc: Returning naked function directly.");
        return objOrFunc
    end;
    local args = EMPTY_ARGS
    if numArgs and numArgs > 0 then
        args = {};
        for i = 1, numArgs do 
            table.insert(args, select(i, ...));
        end;
    end;
    if type(objOrFunc) == "function" then
        --rawdebug("ObjFunc: Returning direct function partial.");
        if funcOrName ~= nil or #args > 0 then
            if args == EMPTY_ARGS then
                args = {};
            end;
            table.insert(args, 1, funcOrName);
        end;
        return function(...) 
            --rawdebug("ObjFunc: Calling direct function partial.");
            return objOrFunc(unpackall(args, {...}));
        end;
    elseif type(funcOrName) == "string" then
        --rawdebug("ObjFunc: Returning string-based method partial.");
        return function(...)
            --rawdebug("ObjFunc: Calling string-based method partial.");
            local func = objOrFunc[funcOrName];
            if not func or type(func) ~= "function" then
                error("Function not found with name: '" .. funcOrName .. "'");
            end;
            return func(objOrFunc, unpackall(args, {...}));
        end;
    elseif type(funcOrName) == "function" then
        --rawdebug("ObjFunc: Returning direct method partial.");
        if not objOrFunc then
            error("Object passed is falsy");
        end;
        return function(...)
            --rawdebug("ObjFunc: Calling direct method partial.");
            return funcOrName(objOrFunc, unpackall(args, {...}));
        end;
    else
        error(format("Invalid parameters given objOrFunc: '%s', funcOrName: '%s'", 
            objOrFunc or "<falsy>", 
            funcOrName or "<falsy>"
        ));
    end;
end;

------------------------------------------
--  Unapplied
------------------------------------------
--
-- This function provides a second level of indirection in function calls. The
-- funcOrName provided here is a method (or method name) to be used on a not-yet-
-- known object. The function returned expects an object, and from that, will return
-- a ObjFunc using the original funcOrName with the given object, along with any
-- arguments passed in.
--
-- You probably won't use this function very often, but it's useful when you want to
-- add ObjFuncs, but don't want to bind the object immediately. We use it to add
-- static listeners: They're registered with the class as Unapplieds, and when 
-- instances of that class are made, the Unapplied static listeners are given the instance
-- where they become ObjFuncs.
function Unapplied(funcOrName, ...)
    local numArgs = select("#", ...);
    if numArgs == 1 then
        return objOrFunc
    end;
    local args = EMPTY_ARGS
    if numArgs and numArgs > 0 then
        args = {};
        for i = 1, select("#", ...) do
            table.insert(args, select(i, ...));
        end;
    end;
    return function(self)
        return ObjFunc(self, funcOrName, unpack(args));
    end;
end;

-------------------------------------------------------------------------------
--
--  Uncategorized Methods
--
-------------------------------------------------------------------------------

function ConvertColorToParts(colorValue)
    local alpha, red, green, blue = 0, 0, 0, 0;
    alpha = bit.rshift(bit.band(colorValue, 0xFF000000), 24) / 255;
    red   = bit.rshift(bit.band(colorValue, 0x00FF0000), 16) / 255;
    green = bit.rshift(bit.band(colorValue, 0x0000FF00),  8) / 255;
    blue  = bit.rshift(bit.band(colorValue, 0x000000FF),  0) / 255;
    return alpha, red, green, blue;
end;

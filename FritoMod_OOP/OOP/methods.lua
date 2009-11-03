if nil ~= require then
    require "FritoMod_OOP/OOP/init";
end;

local OOP = OOP;

-- Integrates a library into a given class. This takes all
-- public (non-double-underscored functions), and adds them
-- to the specified class.
function OOP.IntegrateLibrary(library, class)
    for funcName, func in pairs(library) do
        if not string.match(funcName, "^__") then
            class[funcName] = func;
        end;
    end
end

function OOP.InstanceOf(class, instance)
    assert(OOP.IsClass(class), "class is not a class: " .. tostring(class));
    if not OOP.IsInstance(instance) then
        return false;
    end;
    local candidateClass = instance.class;
    while true do
        if candidateClass == class then
            return true;
        end;
        local super = candidateClass.super;
        if super ~= nil and super ~= candidateClass then
            candidateClass = super;
        else
            break;
        end;
    end;
    return false;
end;

function OOP.IsInstance(candidate)
    return candidate and type(candidate) == "table" and OOP.IsClass(candidate.class);
end;

function OOP.IsClass(candidate)
    return candidate and type(candidate) == "table" and IsCallable(candidate.New) and not candidate.class;
end;


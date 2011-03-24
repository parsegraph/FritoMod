OOP = OOP or {};

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
	if type(candidate) ~= "table" then
		return false;
	end;
    return OOP.IsClass(rawget(candidate, "class"));
end;

function OOP.IsClass(candidate)
	if type(candidate) ~= "table" then
		return false;
	end;
	if rawget(candidate, "class") then
		return false;
	end;
	return IsCallable(rawget(candidate,"New"));
end;


local OOP = OOP;

-- Integrates a library into a given class. This takes all
-- public (non-double-underscored functions), and adds them
-- to the specified class.
OOP.IntegrateLibrary = function(library, class)
    for funcName, func in pairs(library) do
        if not string.match(funcName, "^__") then
            class[funcName] = func;
        end;
    end
end

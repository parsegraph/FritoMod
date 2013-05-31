if nil ~= require then
    require "fritomod/LuaDependency";
    require "fritomod/Ordering";
    require "fritomod/Lists";
    require "fritomod/OOP-Class";
    require "fritomod/currying";
end;

LuaDependencyList = OOP.Class(LuaDependency);

function LuaDependencyList:Constructor()
    self.order = Ordering:New();
end;

function LuaDependency:DependsOn(child, parent)
    self.order:Order(parent, child);
end;

function LuaDependencyList:Output(out, ...)
    return self:DoOutput(Curry(out, ...), self.order:Get());
end;

function LuaDependencyList:DoOutput(out, files)
    error("This method must be overridden");
end;

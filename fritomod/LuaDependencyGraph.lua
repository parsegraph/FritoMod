if nil ~= require then
    require "fritomod/LuaDependency";
    require "fritomod/OOP-Class";
    require "fritomod/currying";
end;

LuaDependencyGraph = OOP.Class(LuaDependency);

function LuaDependencyGraph:Constructor()
	self.childrenOf = setmetatable({}, {
		__index = function(self, key)
			self[key] = {};
			return self[key];
		end
	});
end;

function LuaDependencyGraph:DependsOn(child, parent)
	self.childrenOf[parent][child] = true;
end;

function LuaDependencyGraph:Filter(filter, ...)
    self.childrenOf = Tables.FilterKeys(
        self.childrenOf, filter, ...);
end;

function LuaDependencyGraph:Output(out, ...)
	out = Curry(out, ...);
	return self:DoOutput(out, self.childrenOf)
end;

function LuaDependencyGraph:DoOutput(out, childrenOf)
	error("This method must be overridden");
end;

if nil ~= require then
	require "fritomod/Functions";
	require "fritomod/Lists";
end;

local stack={};

Bindings=setmetatable({
	Push=function(binding)
		Lists.Remove(stack, binding);
		table.insert(stack, binding);
		Bindings.Refresh();
		return Functions.OnlyOnce(function()
			Lists.Remove(stack, binding);
			Bindings.Refresh();
		end);
	end,

	Refresh=function()
		for i=1,#stack do
			local b=stack[i];
			if IsCallable(b) then
				b();
			else
				for keybind, action in pairs(b) do
					SetBinding(keybind, action);
				end;
			end;
		end;
	end
}, {
	__newindex=function()
		error("Cannot directly set a binding");
	end,
	__index=function(self, k)
		k=tostring(k):upper();
		for i=#stack,1,-1 do
			local action=stack[i][k];
			if action ~= nil then
				return action;
			end;
		end;
		return GetBindingByKey(k);
	end
});

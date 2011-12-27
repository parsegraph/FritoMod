if nil ~= require then
	require "fritomod/currying";
	require "fritomod/Lists";
	require "fritomod/Metatables";
end;

function Metatables.OrderedMap(target)
	target = Metatables._AssertTable(target);

	local insertionOrder = {};
	local values = {};

	setmetatable(target, {
		__newindex = function(self, key, value)
			if values[key] ~= nil then
				if value == nil then
					Lists.Remove(insertionOrder, key);
				end;
			elseif key ~= "Iterator" then
				Lists.Insert(insertionOrder, key);
			end;
			values[key] = value;
		end,

		__index = values
	});

	function target:Iterator()
		return Lists.DecorateValueIterator(insertionOrder, function(mappedKey)
			return mappedKey, values[mappedKey];
		end);
	end;

	return target;
end;

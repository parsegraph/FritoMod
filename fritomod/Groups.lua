if nil ~= require then
	-- XXX This requires WoW's Guild functions
	require "fritomod/Mixins-Iteration";
	require "fritomod/GuildMember";
end;

Iterables = Iterables or {};

Groups = Mixins.Iteration();

function Groups.Bias()
	return "table";
end;

local iterated = setmetatable({}, {
	__mode = "k"
});

function Groups._InsertInto(iterable, key, value)
	-- We override this method to clone the returned objects. By default,
	-- we only use one instance.
	if iterated[value] then
		-- It's an iterated value, so clone it so insertions work
		-- properly. Without a clone, we'd end up with insertions
		-- of the exact same reference.
		value = value:Clone();
	end;
	iterable[key] = value;
end;

function Groups.Iterator(name)
	name = name:upper();
	
	if name == "GUILD" then
		local i=0;
		local member = GuildMember:New();
		iterated[member] = true;
		return function()
			i = i + 1;
			if i > GetNumGuildMembers() then
				iterated[member] = nil;
				return nil;
			end
			member:Set(i);
			return member:Name(), member;
		end;
	end;
end;

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

function Groups._InsertInto(iterable, key, value)
	-- We override this method to clone the returned objects. By default,
	-- we only use one instance.
	iterable[key] = value:Clone();
end;

function Groups.Iterator(name)
	name = name:upper();
	
	if name == "GUILD" then
		local i=0;
		local member = GuildMember:New();
		return function()
			i = i + 1;
			if i > GetNumGuildMembers() then
				return nil;
			end
			member:Set(i);
			return member:Name(), member;
		end;
	end;
end;

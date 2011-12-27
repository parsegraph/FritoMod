if nil ~= require then
	require "fritomod/OOP";
	require "fritomod/Strings";
	require "fritomod/Lists";
	require "fritomod/Cursors-Iterable";
end;

-- Splits a camelCase'd or ProperCase'd string into lower-case words. Acronyms will be
-- treated as single words.
--
-- Observe that camelCase's passed into this method will be parsed correctly; the list
-- returned will be {"camel", "Case"}
function Strings.SplitByCase(c)
	assert(c~=nil, "c must not be nil");
	if not OOP.IsInstance(Cursors.Iterable, c) then
		c=Cursors.Iterable:New(tostring(c));
	end;
	local words={};
	while c:MarkNext() do
		local v=c:Get();
		if Strings.IsUpper(v) and not Strings.IsLower(c:Peek()) then
			-- It's an acronym.
			c:PeekUntil(Strings.IsLower);
			if not c:AtEnd() then
				-- We have another word coming up, so back up so we don't capture part of
				-- it, too.
				c:Previous();
			end;
		else
			-- It's a proper-nounized or camel-cased word.
			c:PeekUntil(Strings.IsUpper);
		end;
		table.insert(words, c:MarkSnippet());
	end;
	return words;
end;

function Strings.JoinProperCase(words)
	return Lists.Reduce(words, "", function(camelCase, word)
		return camelCase .. Strings.ProperNounize(word);
	end);
end;

function Strings.JoinCamelCase(words)
	local properString = Strings.JoinProperCase(words);
	return string.lower(string.sub(properString, 1, 1)) .. string.sub(properString, 2);
end;

function Strings.JoinSnakeCase(words)
	return Strings.JoinArray("_", words):lower();
end;

-- Converts AProperCase to aProperCase.
function Strings.ProperToCamelCase(properString)
	return Strings.JoinCamelCase(Strings.SplitByCase(properString));
end;

-- Converts AProperCase to a_proper_case.
function Strings.ProperToSnakeCase(properString)
	return Strings.JoinSnakeCase(Strings.SplitByCase(properString));
end;

-- Converts aProperCase to AProperCase.
function Strings.CamelToProperCase(camelString)
	return Strings.JoinProperCase(Strings.SplitByCase(camelString));
end;

-- Converts aProperCase to a_proper_case.
function Strings.CamelToSnakeCase(camelString)
	return Strings.JoinSnakeCase(Strings.SplitByCase(camelString));
end;

-- Converts a_proper_case to AProperCase
function Strings.SnakeToProperCase(snakeString)
	return Strings.JoinProperCase(Strings.SplitByDelimiter("_", snakeString));
end;

-- Converts a_proper_case to aProperCase
function Strings.SnakeToCamelCase(snakeString)
	return Strings.JoinCamelCase(Strings.SplitByDelimiter("_", snakeString));
end;


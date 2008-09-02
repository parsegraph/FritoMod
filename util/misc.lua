-- FritoMod by Frito

BINDING_HEADER_FRITOMOD = "FritoMod";
BINDING_NAME_RELOAD = "Reload Interface";

function IterateInventory(includeEmpty, receiverFunc)
	if type(includeEmpty) == "function" then
		receiverFunc = includeEmpty;
		includeEmpty = false;
	end;
	local itemLink;
	for bagID = 0, NUM_BAG_SLOTS do
		for slot = 1, GetContainerNumSlots(bagID) do
			itemLink = GetContainerItemLink(bagID, slot);
			if (itemLink or includeEmpty) then
				if receiverFunc(bagID, slot, itemLink, GetContainerItemInfo(bagID, slot)) == false then
					return
				end
			end
		end
	end
end

function GetSmallestStack(itemName)
	local candidateBagID, candidateSlot;
	local candidateCount = 99999 -- Arbitrary large number.
	IterateInventory(function(bagID, slot, itemLink, texture, itemCount, locked, quality, readable)
		if locked or not string.find(itemLink, itemName) or itemCount >= candidateCount then
			return
		end
		candidateBagID = bagID
		candidateSlot = slot
		candidateCount = itemCount
	end)
	return candidateBagID, candidateSlot
end

function GetItemByPriority(...)
	local itemName, bagID, slot;
	for i = 1, select("#", ...) do
		itemName = select(i, ...);
		bagID, slot = GetSmallestStack(itemName);
		if bagID ~= nil then
			return bagID, slot;
		end
	end
end;

function PrintTooltip(tooltip, includeRight) 
	if type(tooltip) == "string" then
		tooltip = getglobal(tooltip);
	end
	if not tooltip then 
		error("DumpTooltip given a falsy tooltip.");
	end
	local tooltipName = tooltip:GetName();
	for i = 1, tooltip:NumLines() do
		debug("Line " .. i .. ", left: '" .. getglobal(tooltipName .. "TextLeft" .. i):GetText() .. "'");
		if includeRight then 
			debug("Line " .. i .. ", right: '" .. getglobal(tooltipName .. "TextRight" .. i):GetText() .. "'");
		end;
	end
end;

local function testFirstAidSpellID(candidate)
	if type(candidate) == "number" then
		-- It's a spell ID, so we need to get the spellname.
		candidate = GetSpellName(candidate, BOOKTYPE_SPELL);
		if not spellName then
			-- It's an invalid ID, so return false.
			return false
		end
	end
	return string.find(candidate, "First Aid")
end;

FIRST_AID_SPELLID = nil;
function getFirstAidSpellID()
	if FIRST_AID_SPELLID ~= nil then
		-- We have a saved ID, so check that for accuracy.
		if testFirstAidSpellID(FIRST_AID_SPELLID) then
			-- It's correct, so return it.
			return FIRST_AID_SPELLID;
		end;
		-- Otherwise, fall through to get a correct spellID.
	end;
	FIRST_AID_SPELLID = nil;
	local spellIDCandidate = 1
	while true do
		local spellName = GetSpellName(spellIDCandidate, BOOKTYPE_SPELL);
		if not spellName then
			do break end;
		end;
		if testFirstAidSpellID(spellName) then
			FIRST_AID_SPELLID = spellIDCandidate;
			return spellIDCandidate
		end;
		spellIDCandidate = spellIDCandidate + 1;
	end
	debug("No valid First Aid SpellID found!")
end

function disableSound()
	SetCVar("Sound_EnableSFX", "0")
end

function enableSound()
	SetCVar("Sound_EnableSFX", "1")
end

function testInclusiveRange(num, min, max)
	return num >= min and num <= max;
end

function testExclusiveRange(num, min, max)
	return num > min and num < max;
end

function toitemstring(itemLink)
	local found, _, itemString = string.find(itemLink, "^|c%x+|H(.+)|h%[.+%]")
	return itemString
end

function tobool(msg)
	return not not msg;
end	

function concat(first, ...)
	local message = ""
	if first then
		message = tostring(first)
	end
	for i = 1, select("#", ...) do
		message = message .. " " .. tostring(select(i, ...))
	end
	return message

end

function say(...)
	SendChatMessage(tostring(concat(...)))
end	

function debug(...)
	ChatFrame1:AddMessage(tostring(concat(...)), 0.0, 0.6, 0.0);
end	

function dump_item(item)
	FritoModTooltip:SetOwner(FritoModFrame, "ANCHOR_NONE");
	FritoModTooltip:SetHyperlink(item);
	for i=1, FritoModTooltip:NumLines() do
	   local line = getglobal("FritoModTooltipTextLeft" .. i)
	   say(line:GetText());
	end
	FritoModTooltip:Hide();
end

function FritoMod_Load()
	FritoModFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function FritoMod_Event(...)
	event = ...
	if event == "PLAYER_ENTERING_WORLD"	then
		getglobal("BuffFrame"):SetAlpha(0);
	end	
end

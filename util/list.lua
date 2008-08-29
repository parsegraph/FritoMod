List = AceLibrary("AceOO-2.0").Class();
local List = List;

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function List.prototype:init(allowDuplicates)
	List.super.prototype.init(self);
	self.values = {};
	self.allowDuplicates = allowDuplicates;
end;

-------------------------------------------------------------------------------
--
--  Value Manipulation Methods
--
-------------------------------------------------------------------------------

function List.prototype:Add(value)
	if not self.allowDuplicates and self:Contains(value) then
		return false;
	end;
	table.insert(self.values, value);
	self:DoAdd(value);
	return true;
end;

function List.prototype:AddAll(values)
	local addedAll = true;
	for _, value in ipairs(values) do
		local success = self:Add(value);
		if addedAll and not success then
			addedAll = false;
		end
	end;
	return addedAll;
end;

function List.prototype:Remove(value)
	for index, candidate in ipairs(self.values) do
		if candidate == value then
			self:RemoveAt(index);
			if self.allowDuplicates then
				self:Remove(value);
				return true;
			end;
		end;
	end;
	return false;
end;

function List.prototype:RemoveAt(index)
	table.remove(self.values, index);
	self:DoRemove(value);
end;

function List.prototype:Clear()
	local values = self:GetValues();
	for index, value in ipairs(values) do
		self:DoRemove(value);
	end;
	while #values do
		table.remove(values);
	end;
end;

function List.prototype:DoAdd(value)
	-- Pass for now.
end;

function List.prototype:DoRemove(value)
	-- Pass for now.
end;

function List.prototype:Filter(filterFunc)
	local removingIndices;
	local removedList;
	for index, item in ipairs(self:GetValues()) do
		if not filterFunc(item, index, list) then
      if not removingIndices then
        removingIndices = {};
        removedList = {};
      end;
			table.insert(removingIndices, index);
			table.insert(removedList, item);
		end;
	end;
  local offset = 0;
	if removingIndices then
    for _, index in ipairs(removingIndices) do
      self:RemoveAt(index - offset);
      offset = offset + 1;
    end;
  end;
	return removedList;
end;

-------------------------------------------------------------------------------
--
--  Value Introspection Methods
--
-------------------------------------------------------------------------------

function List.prototype:Get(index)
  return self:GetValues()[index];
end;

function List.prototype:IsEmpty()
	for value in self:Iter() do 
		return true;
	end;
	return false;
end;

function List.prototype:Length()
  return #self.values;
end;

function List.prototype:GetValues()
	return self.values;
end;

function List.prototype:Iter()
	local index = 0;
	local entries = #(self.values);
	return function()
		index = index + 1;
		if index <= entries then
			return self.values[index];
		end;
	end;
end;

function List.prototype:GetIndex(value)
	for index, candidate in ipairs(self.values) do
		if candidate == value then
			return index;
		end;
	end;
end;

function List.prototype:Contains(value)
	return tobool(self:GetIndex(value));
end;

function List.prototype:GetLength()
	return #self.values;
end;

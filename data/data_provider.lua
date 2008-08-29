DataProvider = AceLibrary("AceOO-2.0").Class(EventDispatcher);
local DataProvider = DataProvider;

DataProvider.events = { UPDATE = "DataProvider_Update", END = "DataProvider_End"};

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function DataProvider.prototype:init(tags, initialValue)
	DataProvider.super.prototype.init(self);
	self.tags = tags;
	self:SetValue(initialValue);
	self:Register();
end;

function DataProvider.prototype:Register()
	DataRegistry:RegisterDataProvider(self);
end;

function DataProvider.prototype:Unregister()
	DataRegistry:UnregisterDataProvider(self);
end;

-------------------------------------------------------------------------------
--
--  Triggers
--
-------------------------------------------------------------------------------

function DataProvider.prototype:TriggerUpdate()
	self:TriggerEvent(DataProvider.events.UPDATE, self);
end;

function DataProvider.prototype:TriggerEnd()
	self:TriggerEvent(DataProvider.events.END, self);
end;

-------------------------------------------------------------------------------
--
--  Getters and Setters
--
-------------------------------------------------------------------------------

------------------------------------------
--  Tags
------------------------------------------

function DataProvider.prototype:GetTag(tag)
	return self.tags[tag];
end;

function DataProvider.prototype:IterTags()
	return next, self.tags, nil;
end;

------------------------------------------
--  Value
------------------------------------------

function DataProvider.prototype:GetValue()
	return self.value;
end;

function DataProvider.prototype:SetValue(value)
	if self:GetValue() == value then
		return;
	end;
	self.value = value;
	self:TriggerUpdate();
end;

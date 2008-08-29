DataListener = FritoLib.OOP.Class();
local DataListener = DataListener;

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function DataListener.prototype:init(tags, listenerFunc, listenerSelf)
	DataProvider.super.prototype.init(self);
	self.tags = tags;
	self.listener = ObjFunc(listenerFunc, listenerSelf);
	self.attached = {};
end;

-------------------------------------------------------------------------------
--
--  Listener Methods
--
-------------------------------------------------------------------------------

function DataListener.prototype:Attach(dataProvider)
	if self.attached[dataProvider] then
		return;
	end;
	self.attached[dataProvider] = {
		dataProvider:AddListener(DataProvider.events.UPDATE, self.listener);
		dataProvider:AddListener(DataProvider.events.END, self.listener);
	};
	self:TriggerUpdateWith(dataProvider);
end;

function DataListener.prototype:Detach(dataProvider)
	local detachers = self.attached[dataProvider];
	if not detachers then
		return;
	end;
	for _, func in ipairs(detachers) do
		func();
	end;
	self.attached[dataProvider] = nil;
end;

function DataListener.prototype:DetachAll()
	for dataProvider, _ in pairs(self.attached) do
		self:Detach(dataProvider);
	end;
end;

function DataListener.prototype:TriggerUpdateWith(dataProvider)
	self.listener(DataProvider.events.UPDATE, dataProvider);
end;

-------------------------------------------------------------------------------
--
--  Introspection Methods
--
-------------------------------------------------------------------------------

function DataListener.prototype:IterTags()
	return next, self.tags, nil;
end;

function DataListener.prototype:GetTags()
	return self.tags;
end;

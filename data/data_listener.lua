DataListener = FritoLib.OOP.Class();
local DataListener = DataListener;

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function DataListener.prototype:init(tags, ...)
	DataProvider.super.prototype.init(self);
	self.tags = tags;
	self.listener = ObjFunc(...);
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
	self.attached[dataProvider] = dataProvider:Attach(self.listener, self)
	self:TriggerUpdateWith(dataProvider);
end;

function DataListener.prototype:Detach(dataProvider)
	local detacher = self.attached[dataProvider];
	if not detacher then
		return;
	end;
    detacher()
	self.attached[dataProvider] = nil;
end;

function DataListener.prototype:DetachAll()
	for dataProvider, _ in pairs(self.attached) do
		self:Detach(dataProvider);
	end;
end;

-- Force an asynchronous update for this DataListener. Used on initial connection.
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

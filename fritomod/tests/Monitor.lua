local Suite = CreateTestSuite("fritomod.Monitor");

function Suite:Tick(value)
	self.time=self.time+value;
	Timing._Tick(value);
end;

Suite:AddListener(Metatables.Noop({
	TestStarted = function(self, suite)
		self.oldGetTime=GetTime;
		suite.time=0;
		GetTime=function()
			return suite.time;
		end;
		self.listeners = ListenerList:New("Dummy Monitor");
		self.remover=Timing._Mask(self.listeners);
	end,
	TestFinished = function(self, suite)
		GetTime=self.oldGetTime;
		self.listeners=nil;
		self.remover();
	end
}));

function Suite:TestMonitor()
	local t = Monitor:New();
	t:SetWithDuration("5s");
	assert(t:IsActive());
	self:Tick(10);
	assert(t:IsComplete());
end;

function Suite:TestMonitorAlreadyCompleted()
	local t = Monitor:New();
	t:SetWithDuration("5s", "6s");
	assert(t:IsActive());
	assert(t:IsComplete());
end;

function Suite:TestMonitorStateOrder()
	local states = {};

	local t = Monitor:New();
	t:StateListener(table.insert, states);

	t:SetWithDuration("5s");
	self:Tick(10);
	t:Destroy();

	Assert.Equals({
		"Active",
		"Complete",
		"Inactive"
	}, states);
end;

function Suite:TestMonitorStateOrderWithChange()
	local states = {};

	local t = Monitor:New();
	t:StateListener(table.insert, states);

	t:SetWithDuration("5s");
	self:Tick(2);
	t:SetWithDuration("7s"); -- Delay it
	self:Tick(15);
	t:Destroy();

	Assert.Equals({
		"Active",
		"Changed",
		"Complete",
		"Inactive"
	}, states);
end;

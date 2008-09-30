FritoMod = {};
local FritoMod = FritoMod;

function FritoMod:OnEnable()
    MasterLog = Log("FritoMod");
    FritoMod.masterLogReleaser = MasterLog:Pipe(API.Chat.mediums.DEBUG);

	--IterationManager.GetInstance():Attach(self);
    --IterationManager.GetInstance():AddPreprocessor(TimerManager, "OnUpdate");
end

function FritoMod:OnDisable()
	IterationManager.GetInstance():Detach(self);
    FritoMod.masterLogReleaser();
    FritoMod.masterLogReleaser = nil;
end

function FritoMod:RunTests()
    local releaser = TestManager.log:SyndicateTo(MasterLog);
    TestManager:Run();
    releaser();
end;

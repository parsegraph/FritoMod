IterationManager = FritoLib.OOP.Class(EventDispatcher);
local IterationManager = IterationManager;

IterationManager.EVENT_UPDATE = "UpdateEvent";
IterationManager.EVENT_PREPROCESS = "PreprocessEvent";
IterationManager.EVENT_POSTPROCESS = "PostprocessEvent";

IterationManager.FRAMERATE = .05;

function IterationManager:GetInstance()
	local instance = IterationManager._instance;
	if not instance then
		instance = IterationManager:new();
		IterationManager._instance = instance;
	end;
	return instance;
end;

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function IterationManager.prototype:init()
	IterationManager.super.prototype.init(self);
	
	-- Explicitly add our TimerManager to this loop.
	self:AddPreprocessor(TimerManager.OnUpdate, TimerManager);
end;

-------------------------------------------------------------------------------
--
--  Convenience Attachment Methods
-- 
-------------------------------------------------------------------------------

function IterationManager.prototype:Attach(aceEvent, framerate)
	framerate = framerate or IterationManager.FRAMERATE;
	aceEvent:ScheduleRepeatingEvent(IterationManager.EVENT_UPDATE, self.OnUpdate, framerate, self);
end;

function IterationManager.prototype:Detach(aceEvent)
	aceEvent:UnscheduleRepeatingEvent(IterationManager.EVENT_UPDATE, self.OnUpdate, framerate, self);
end;

-------------------------------------------------------------------------------
--
--  Processor Manipulation Methods
-- 
-------------------------------------------------------------------------------

function IterationManager.prototype:AddPreprocessor(...)
	return self:AddListener(IterationManager.EVENT_PREPROCESS, ...);
end;

function IterationManager.prototype:AddPostprocessor(...)
	return self:AddListener(IterationManager.EVENT_POSTPROCESS, ...);
end;

-------------------------------------------------------------------------------
--
--  Iteration Utility and Listeners
-- 
-------------------------------------------------------------------------------

function IterationManager.prototype:OnUpdate()
	self:TriggerEvent(IterationManager.EVENT_PREPROCESS);
	Stage.GetStage():ValidateNow();
	self:TriggerEvent(IterationManager.EVENT_POSTPROCESS);
end;

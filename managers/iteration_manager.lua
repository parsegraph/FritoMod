IterationManager = OOP.Class(EventDispatcher, OOP.Singleton);
local IterationManager = IterationManager;

IterationManager.EVENT_UPDATE = "UpdateEvent";
IterationManager.EVENT_PREPROCESS = "PreprocessEvent";
IterationManager.EVENT_POSTPROCESS = "PostprocessEvent";

IterationManager.FRAMERATE = .05;

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function IterationManager:__Init()
	IterationManager.super.__Init(self);
end;

-------------------------------------------------------------------------------
--
--  Convenience Attachment Methods
-- 
-------------------------------------------------------------------------------

function IterationManager:Attach(aceEvent, framerate)
	framerate = framerate or IterationManager.FRAMERATE;
	aceEvent:ScheduleRepeatingEvent(IterationManager.EVENT_UPDATE, self.OnUpdate, framerate, self);
end;

function IterationManager:Detach(aceEvent)
	aceEvent:UnscheduleRepeatingEvent(IterationManager.EVENT_UPDATE, self.OnUpdate, framerate, self);
end;

-------------------------------------------------------------------------------
--
--  Processor Manipulation Methods
-- 
-------------------------------------------------------------------------------

function IterationManager:AddPreprocessor(...)
	return self:AddListener(IterationManager.EVENT_PREPROCESS, ...);
end;

function IterationManager:AddPostprocessor(...)
	return self:AddListener(IterationManager.EVENT_POSTPROCESS, ...);
end;

-------------------------------------------------------------------------------
--
--  Iteration Utility and Listeners
-- 
-------------------------------------------------------------------------------

function IterationManager:OnUpdate()
	self:TriggerEvent(IterationManager.EVENT_PREPROCESS);
	Stage.GetStage():ValidateNow();
	self:TriggerEvent(IterationManager.EVENT_POSTPROCESS);
end;

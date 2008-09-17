FritoLib = AceLibrary("AceAddon-2.0"):new(
	"AceConsole-2.0", 
	"AceDB-2.0", 
	"AceEvent-2.0",
	"FuBarPlugin-2.0"
);

local FritoLib = FritoLib;
FritoLib.revision = "Unreleased";

FritoLib.OOP = AceLibrary("AceOO-2.0");

-- Get our database.
FritoLib:RegisterDB("FritoLibDB");
FritoLib:RegisterDefaults("profile", {});

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function FritoLib:OnInitialize()
	-- Pass for now
end;

-------------------------------------------------------------------------------
--
--  Event Listeners
-- 
-------------------------------------------------------------------------------

function FritoLib:OnEnable()
    MasterLog = Log:new("FritoMod");
    MasterLog:Pipe(API.Chat.mediums.DEBUG);

	self:OnProfileEnable();
	IterationManager.GetInstance():Attach(self);
    IterationManager.GetInstance():AddPreprocessor(TimerManager, "OnUpdate");
end

function FritoLib:OnDisable()
	self:OnProfileDisable();
	IterationManager.GetInstance():Detach(self);
end

function FritoLib:OnProfileEnable()
	-- Pass for now.
end

function FritoLib:OnProfileDisable()
	-- Pass for now.
end

function FritoLib:RunTests()
    local releaser = TestManager.log:SyndicateTo(MasterLog);
    TestManager:Run();
    releaser();
end;

------------------------------------------
--  FuBar Stuff
------------------------------------------

FritoLib.hasIcon = false
FritoLib.hasNoColor = true
FritoLib.clickableTooltip = false
FritoLib.hideWithoutStandby = true
FritoLib.cannotDetachTooltip = true

FritoLib.Options = {
	type = 'group',
	handler = FritoLib,
	args = {
        test = {
            type = 'execute',
            name = "Run Regression Tests",
            desc = "Run Tests for FritoMod",
            func = "RunTests",
        },
		class = {
			type = 'text',
			name = "Class", 
			desc = "Set your class",
			get = function()
				return myName
			end,
			set = function(name)
				myName = name
			end,
			validate = {"Warrior", "Warlock", "Druid"}
		},
	},
};
FritoLib.OnMenuRequest = FritoLib.Options;

FritoLib:RegisterChatCommand({"/fritomod", "/fm", "/frito"}, FritoLib.Options);

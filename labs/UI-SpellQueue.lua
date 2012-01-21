if nil ~= require then
	require "fritomod/currying";
	require "fritomod/OOP-Class";
	require "fritomod/Anchors";
	require "fritomod/UI-Icon";
	require "fritomod/Monitor";
	require "fritomod/Metatables-StyleClient";
	require "fritomod/Frames";
	require "labs/UI-SpellQueueItem";
end;

local DEFAULT_STYLE = {
	frequency = .1,

	maxDistance = 150,

	pendingAlpha = .4,

	hideDuration = 1
};

local SpellQueue = OOP.Class();
UI.SpellQueue = SpellQueue;

function SpellQueue:Constructor(parent, style)
	parent = Frames.AsRegion(parent);
	assert(Frames.IsRegion(parent), "Parent frame must be provided");
	self.style = Metatables.StyleClient(style);
	self.style:Inherits(DEFAULT_STYLE);

	self.monitors = {};
	self.icons = {};

	self.root = CreateFrame("Frame", nil, parent);
	-- TODO Provide a style to make this vertical, rather than horizontal
	self.root:SetWidth(150);
	self.root:SetHeight(50);
end;

function SpellQueue:SetCurrent(icon)
	local monitor = self.monitors[1];
	if not monitor then
		return;
	end;
	icon:SetCurrent(monitor);
	self.currentIcon = icon;
	Anchors.Clear(icon);
	Frames.Show(icon);

	-- Move the icon closer to the root frame as the cooldown diminishes.
	local translator = icon:OnState("Cooldown", Timing.Every, self.style.frequency, function(self)
		-- TODO Make HFlip be a style, not inlined.
		Anchors.Share(icon, self.root, "left", monitor:Interpolate(self.style.maxDistance, 0));
	end, self);

	local onReady = icon:OnState("Ready", function()
		Anchors.Share(icon, self.root, "left", 0);
		translator();
	end);

	local transitioner = Callbacks.OnlyOnce(Curry(icon, "OnState", "Fired"), function(self)
		assert(self.monitors[1] == monitor, "Monitors are out of order!");
		table.remove(self.monitors, 1);
		self:SetCurrent(self.pendingIcon);
		self:SetPending();
	end, self);

	local removers = {
		transitioner,
		onReady,
		translator,
		Seal(icon, "SetMonitor")
	};

	local destructor = Curry(Lists.CallEach, removers);

	local destroyOnceFired = icon:OnState("Fired", Callbacks.OnlyOnce,
		Curry(icon, "OnState", "Inactive"), destructor);
end;

function SpellQueue:SetPending()
	local monitor = self.monitors[2];
	if not monitor then
		return;
	end;

	local icon = self:GetFreeIcon();
	icon:SetPending(monitor);
	Frames.Show(icon);
	self.pendingIcon = icon;

	local firstIcon = self.currentIcon;
	local firstMonitor = self.monitors[1];

	Anchors.Clear(icon);
	Anchors.HFlip(icon, self.root, "right", 3);

	-- Fade in the second icon as the first becomes closer to being off cooldown.
	local fadeIn = firstIcon:OnState("Cooldown", Timing.Every, self.style.frequency, function(self)
		Frames.Alpha(icon, firstMonitor:Interpolate(0, self.style.pendingAlpha));
	end, self);

	local onReady = firstIcon:OnState("Ready", Frames.Alpha, icon, self.style.pendingAlpha);

	firstIcon:OnState("Inactive", Lists.CallEach, {
		fadeIn,
		onReady
	});
end;

function SpellQueue:Queue(monitor)
	table.insert(self.monitors, monitor);
	if #self.monitors == 1 then
		-- This is the current action, so start displaying it immediately.
		self:SetCurrent(self:GetFreeIcon());
	elseif #self.monitors == 2 then
		-- This is the pending action, so start displaying it immediately.
		self:SetPending();
	else
		-- We already have the current and pending actions set, so we don't need to display anything.
	end;
end;

-- Return an unused SpellQueueItem.
function SpellQueue:GetFreeIcon()
	for i=1, #self.icons do
		if self.icons[i]:State() == "Inactive" then
			return self.icons[i];
		end;
	end;
	table.insert(self.icons, UI.SpellQueueItem:New(self.root, self.style));
	return self.icons[#self.icons];
end;

function SpellQueue:Anchor(anchor)
	self.anchor = anchor;
	return self.root;
end;

function SpellQueue:Destroy()
	Frames.Destroy(self.root);
	Frames.Destroy(self.icons);
end;

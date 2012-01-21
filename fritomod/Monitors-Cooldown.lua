if nil ~= require then
	-- XXX We require WoW's GetSpellCooldown, GetItemCooldown
	require "fritomod/Timing";
	require "fritomod/Monitor";
end;

Monitors = Monitors or {};

function Monitors.MyCooldown(name, frequency)
	local m = Monitor:New(name);
	frequency = frequency or .5;

	local function UpdateCooldown()
		m:SetValue(name);
		local startTime, duration, enabled = GetSpellCooldown(name);
		if not startTime then
			-- Not a spell, so maybe it's an item.
			startTime, duration, enabled = GetItemCooldown(name);
		end;
		if not startTime then
			-- Not a spell or an item, so we consider it inactive.
			m:Destroy();
			return;
		end;
		if enabled == 0 then
			-- The action is currently active, so we consider it completed.
			m:SetCompleted();
			return;
		end;
		if duration == 0 then
			-- The action is ready to be used, so we consider it completed.
			m:SetCompleted();
			return;
		end;
		if startTime then
			m:SetWithBounds(
				startTime + duration,
				startTime
			);
			return;
		end;
	end;
	m:AddInstaller(Timing.Every, frequency, UpdateCooldown);

	-- Update immediately, in addition to the timer.
	m:AddInstaller(UpdateCooldown);

	return m;
end;
Monitors.MyCooldowns = Monitors.MyCooldown;
Monitors.MyCoolDowns = Monitors.MyCooldown;
Monitors.MyCoolDown = Monitors.MyCooldown;

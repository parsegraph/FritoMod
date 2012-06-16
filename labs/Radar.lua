Labs = Labs or {};

function Labs.Radar()

	-- detects nearby enemy players

	--usage:
	-- /radar -- toggles
	-- /radar on | off -- obvious
	-- /radar <number> -- sets how fast it will save data on a person before deleting
	-- /radar seek -- toggles target info and spam
	-- /radar seek <namesearch> -- adds that target to the seek list
	-- /radar seek <number> -- sets how long between reports -- default 5 seconds
	-- /radar unseek -- unseeks everyone
	-- /radar unseek <namesearch> -- adds that target to the seek list

	-- prevents unaccessable frames with registered events
	if not GLOBAL_RADARFRAME then
	   GLOBAL_RADARFRAME = CreateFrame("FRAME")
	end
	-- to make shit easier on my poor fingers
	local f=GLOBAL_RADARFRAME
	-- converts a string into an array of the various words
	local function StringSplit(subject)
	   local words = {}
	   -- finds any words
	   for word in string.gmatch(subject,"%w+") do
		  table.insert(words,word)
	   end
	   return words
	end

	-- can get race but not faction
	-- used because no built in dec to hex for the flags and I'm not making one
	local HORDE = {
	   ["Troll"] = true,
	   ["Orc"] = true,
	   ["Undead"] = true,
	   ["Blood Elf"] = true,
	   ["Tauren"] = true,
	   ["Goblin"] = true
	}

	local ALLIANCE = {
	   ["Gnome"] = true,
	   ["Dwarf"] = true,
	   ["Human"] = true,
	   ["Night Elf"] = true,
	   ["Draenei"] = true,
	   ["Worgen"] = true
	}
	-- the players faction
	local FACTION = ALLIANCE

	local CORPSERUN = 300
	local TIMER = 30 -- how long in seconds before reporting the same person
	local RADAR -- status "ON" or "OFF"
	local ENEMY = {} -- array of detected enemies
	local SEEKING = {} -- array of targets actually looking for
	local SEEK_ALL
	local SEEK_TIMER = 5

	-- the main function
	f:SetScript("OnEvent",function(self, mainEvent, timestamp, secondEvent,hideCaster, sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,spellid,spellName)
		  local knownTypes = {[0]="player", [3]="NPC", [4]="pet", [5]="vehicle"}
		  local race,class
		  local enemyName,enemyTarget = nil,nil
		  --converts the 5th char of the GUID string to a hex number
		  local B = tonumber(sourceGUID:sub(5,5), 16)
		  local C = tonumber(destGUID:sub(5,5), 16)
		  -- finding out if its the source or the target that is the enemy player
		  -- defaults to source
		  if knownTypes[C] == "player" and destName then
		     class = GetPlayerInfoByGUID(destGUID)
		     race = select(3,GetPlayerInfoByGUID(destGUID))
		     if not FACTION[race] then
		        enemyName = destName
		        enemyTarget = sourceName
		     end
		  end
		  if knownTypes[B] == "player" and sourceName then
		     class = GetPlayerInfoByGUID(sourceGUID)
		     race = select(3,GetPlayerInfoByGUID(sourceGUID))
		     if not FACTION[race] then
		        enemyName = sourceName
		        enemyTarget = destName
		     end
		  end

		  -- if we have found an enemy
		  if enemyName then
		     if ENEMY[enemyName] then
		        ENEMY[enemyName].timeLast=timestamp
		        -- next combat log event affecting the enemy player after they were killed
		        if ENEMY[enemyName].dead then
		           print("Ressed:",enemyName,race,class)
		           ENEMY[enemyName].dead = nil
		        end
		        -- target info spam for trying to find them
		        if SEEKING[enemyName] then
		           if (timestamp - ENEMY[enemyName].timeStart) > SEEK_TIMER then
		              ENEMY[enemyName].timeStart = timestamp
		              if enemyTarget then
		                 print(race,class,enemyName,"|",enemyTarget)
		              else
		                 print(race,class,enemyName)
		              end
		           end
		        end
		        -- says the target is trying to be a sneaky son of a bitch

		        local invisTypes = {"invis","stealth","prowl","shadowmeld","camo" }
		        if type(spellName) == "string" then
		           local tempName = string.lower(spellName)
		           for k,v in pairs(invisTypes) do
		              if string.match(v,tempName) then
		                 print("--------->",enemyTarget,spellName,"<--------")
		              end
		           end
		        end

		     else
		        -- first time detection prints info
		        ENEMY[enemyName] = {race=race,class=class, timeStart=timestamp,timeLast=timestamp}
		        if enemyTarget then
		           print(race,class,enemyName,"",enemyTarget)
		        else
		           print(race,class,enemyName)
		        end
		     end
		  end

		  -- may result in strange printings in times of intense afkness in an empty zone -- use wth caution
		  for k,v in pairs(ENEMY) do
		     if SEEK_ALL then
		        SEEKING[k] = true
		     end
		     if v.dead then
		        -- give a dead player a much longer time before assuming they have moved on
		        if (timestamp - v.timeLast) > CORPSERUN then
		           print("No longer detected:",k,v.race,v.class)
		           ENEMY[k] = nil
		        end
		        -- after TIMER since last combat event from that player then assume they have moved on
		        -- does not stop seek spam from the target if they are rediscovered
		     elseif (timestamp - v.timeLast) > TIMER then
		        print("No longer detected:",k,v.race,v.class)
		        ENEMY[k] = nil
		     end
		  end
		  -- an enemy player died so give them time to run back to corpse
		  if secondEvent == "UNIT_DIED" and ENEMY[destName] then
		     local v = ENEMY[destName]
		     print("Killed:",destName,v.race,v.class)
		     ENEMY[destName].dead = true
		  end

	end)
	-- searches for a string inside enemies names
	local function FindName(name)
	   for k,v in pairs(ENEMY) do
		  if string.match(string.lower(k),name) then
		     return k
		  end
	   end
	   return nil
	end

	-- target info spam for this target
	local function SeekTarget(target)
	   local name = FindName(target)
	   if name then
		  SEEKING[name] =  true
		  print("Seeking:",name)
	   else
		  print(target,"not found")
	   end
	end
	-- turns off target info spam for this target
	local function UnSeekTarget(target)
	   local name = FindName(target)
	   if name then
		  SEEKING[name] =  nil
		  print("Unseeking:",name)
	   else
		  print(target,"not found")
	   end
	end

	-- turns enemytarget info spam on
	local function SeekAllOn()
	   SEEK_ALL = true
	end
	-- turns enemytarget info spam off
	local function SeekAllOff()
	   for k,v in pairs(ENEMY) do
		  SEEKING[k] = nil
	   end
	   SEEK_ALL = false
	end
	-- toggles enemy target info spam
	local function ToggleSeekAll()
	   if SEEK_ALL  then
		  SeekAllOff()
		  print("Unseeking: All")
	   else
		  SeekAllOn()
		  print("Seeking: All")
	   end
	end

	-- dur
	local function RadarOn()
	   f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	   RADAR = "ON"
	   print("Radar: ",RADAR)
	end
	-- dur
	local function RadarOff()
	   f:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	   RADAR = "OFF"
	   for k,v in pairs(ENEMY) do
		  ENEMY[k] = nil
	   end
	   SeekAllOff()
	   print("Radar: ",RADAR)
	end
	-- huh?
	local function ToggleRadar()
	   if RADAR == "OFF" then
		  RadarOn()
	   else
		  RadarOff()
	   end
	end

	-- this naming convention is stupid
	local function SlashHandler(args)
	   local cmds = {}
	   cmds = StringSplit(string.lower(args))

	   if cmds[1] == "on" then
		  RadarOn()
	   elseif cmds[1] == "off" then
		  RadarOff()
	   elseif type(cmds[1]) == "number" then
		  TIMER = args
		  print("Time until missing:", TIMER)
	   elseif cmds[1] == "seek" then
		  if cmds[2] then
		     if cmds[2] ==  "on" then
		        SeekAllOn()
		        if RADAR == "OFF" then
		           RadarOn()
		        end
		        print("Seeking: All")
		     elseif cmds[2] == "all" then
		        SeekAllOn()
		        if RADAR == "OFF" then
		           RadarOn()
		        end
		        print("Seeking: All")
		     elseif cmds[2] == "off" then
		        SeekAllOff()
		        print("Unseeking: All")
		     elseif type(cmds[2]) == "number" then
		        SEEK_TIMER = cmds[2]
		     else
		        SeekTarget(cmds[2])
		     end
		  else
		     ToggleSeekAll()
		  end
	   elseif cmds[1] == "unseek" then
		  if cmds[2] then
		     if cmds[2] == "all" then
		        SeekAllOff()
		     else
		        UnSeekTarget(cmds[2])
		     end
		  else
		     SeekAllOff()
		  end
	   else
		  ToggleRadar()
	   end
	end
	-- your mom is stupid
	RadarOff()

	RegisterSlash(SlashHandler,"radar")
end


--------------------------------------------------------------------------------
-- Original Author: Eric Tetz <erictetz@gmail.com> 2008
-- Hack. Ingame Lua editing and compiling. Frito. Thonik.
--------------------------------------------------------------------------------

if nil ~= require then
    require "hack/Indent";
    require "wow/api/Units";
    require "wow/api/Sound";
    require "wow/Dialogs";
    require "fritomod/Remote";
    require "fritomod/Timing";
    require "fritomod/Tables";
	require "fritomod/Callbacks-Frames";
end;

local HackDB = { -- default settings saved variables
    font = 2,
    fontsize = 15,
    snap = 1,
    pages = { untitled = {name = "untitled", data='',index=1,} },
    order = {"untitled"}, --list that the index points to the page name
    autoapproved = {},
    sharing = {},
    colorTable = 1
}

Hack = Hack or {};
Tables.Update(Hack, {
    tooltips = {
        HackNew         = 'Create new %s',
        HackDelete      = 'Delete this %s\nSHIFT to skip confirmation prompt',
        HackRename      = 'Rename this %s',
        HackMoveUp      = 'Move this %s up in the list\nSHIFT to move in increments of 5',
        HackMoveDown    = 'Move this %s down in the list\nSHIFT to move in increments of 5',
        HackAutorun     = 'Run this page automatically when Hack loads',
        HackRun         = 'Run this page',
        HackSend        = 'Send this page to another Hack user',
        HackCopy        = 'Copy the selected page',
        HackSync        = 'Sync this page with another Hack user\n',
        HackStopSync    = 'Stop syncing this page with the chosen Hack user\n',
        HackSnap        = 'Attach editor to list window',
        HackEditClose   = 'Close editor for this page',
        HackFontCycle   = 'Cycle through available fonts',
        HackFontBigger  = 'Increase font size',
        HackFontSmaller = 'Decrease font size',
        HackRevert      = 'Revert to saved version of this page',
        HackColorize    = 'Enable Lua syntax highlighting for this page',
        HackSearchEdit  = 'Find %ss matching this text\nENTER to search forward\nSHIFT+ENTER to search backwards',
        HackSearchName  = 'Search %s name',
        HackSearchBody  = 'Search page text',
    },
    fonts = {
        Media.font.veramono,
        Media.font.inconsolata,
        Media.font.frizqt,
        Media.font.arial
    },
    colorTables = { -- found in Indent.lua
        HackIndent.hackColorTable,
        HackIndent.defaultColorTable,
    },
    tab = '   ',
    ListItemHeight =  17, -- used in the XML, too
    ListVOffset    =  37, -- vertical space not available for list items
    MinHeight      = 141, -- scroll bar gets wonky if we let the window get too short
    MinWidth       = 296, -- keep buttons from crowding/overlapping
    MinEditWidth   = 486, -- keep buttons from crowding/overlapping
    MaxWidth       = 572, -- tune to match size of 200 character page name
    MaxVisible     =  50, -- num visible without scrolling; limits num HackListItems we must create
    NumVisible     =   0, -- calculated during list resize
});

BINDING_HEADER_HACK = 'Hack'  -- used by binding system

local SYNC_ACCEPTING = 1;
local SYNC_ACCEPTED = 2;

local PROTECT_SCRIPTS = false;

local PLAYERNAME = UnitName('player')

function Hack.Upgrade(HackDB)
local maxVersion = "1.2.5"
if HackDB.version and maxVersion == HackDB.version then return end -- don't need to load tables and shit if not needed
    -- all upgrades need to use functions and variables found only within that upgrade
    -- saved variables will have to be used; that is kind of the point of this
    local upgrades = {
        ["1.1.0"] = function(self) -- from
            if not HackDB.books then HackDB.version = "1.2.0" return end-- maybe they have deleted all their saved vars.
            if not HackDB.order then HackDB.order = {} end -- thought this was taken care of in the default stuff above?
            if not HackDB.pages then HackDB.pages = {} end
            local pages, order = {},{}
            for _,book in ipairs(HackDB.books) do
                for _,page in ipairs(book.data) do
                    if not pages[page.name] then -- don't want to overwrite anything
                        pages[page.name] = page -- table[''] is valid!
                        table.insert(order, page.name)
                        pages[page.name].index = #order
                    else
                        for i=2,#order+2 do -- first copy is name(2) etc,maybe all things are the same name!
                            if not pages[page.name..'('..i..')'] then
                                local n = page.name..'('..i..')'
                                pages[n] = page
                                pages[n].name = n
                                table.insert(order,n)
                                pages[n].index = #order
                                break
                            end
                        end
                    end
                end
            end
            HackDB.books = nil
            HackDB.book = nil
            HackDB.pages = pages
            HackDB.order = order
            HackDB.version = "1.2.0" -- to
        end,
        ["1.2.0"] = function(self)
            if not HackDB.colorTable then HackDB.colorTable = 1 end
        HackDB.version = "1.2.1"
        end,
        ["1.2.1"] = function(self)
            HackDB.autoapproved={}
            HackDB.version = "1.2.2"
        end,
        ["1.2.2"] = function(self)
            HackDB.sharing={}
            HackDB.version = "1.2.3"
        end,
        ["1.2.3"] = function(self)
            for _, senders in pairs(HackDB.sharing) do
                for i=1,#senders do
                    senders[senders[i]]=true;
                end;
                while #senders > 0 do
                    table.remove(senders);
                end;
            end;
            HackDB.version = "1.2.4"
        end,
        ["1.2.4"] = function(self)
			local oldApproved = HackDB.autoapproved;
            HackDB.autoapproved = {};
			for name, app in pairs(oldApproved) do
				if(type(app) == "table") then
					HackDB.autoapproved[name] = app;
				end;
			end;
            HackDB.version = "1.2.5"
        end,
    }

    if not HackDB.version then
        HackDB.version = "1.1.0"
    end
    while HackDB.version ~= maxVersion do
        local tempVersion = HackDB.version -- preventing nub infinite loop

        if upgrades[HackDB.version] then
            upgrades[HackDB.version]()
            if tempVersion == HackDB.version then
                error("Continuously trying to upgrade from "..HackDB.version)
            end
        else
            error("Can't upgrade from "..HackDB.version)
        end
    end
end

function CreateColorSwatchPanel()
	local background = Frames.New();
	background:SetFrameStrata("DIALOG");
	frameSize = 0.52;
	local selectedColor = {1,1,1};

	local classes = {
	   "Druid",
	   "Hunter",
	   "Mage",
	   "Paladin",
	   "Priest",
	   "Rogue",
	   "Shaman",
	   "Warlock",
	   "Warrior",
	   "DeathKnight",
	   "Monk",
	   "DemonHunter"
	};

	Frames.WH(background, frameSize*800, frameSize*800);
	Anchors.Flip(background, Anchors.Saved("Fritomod.Swatches"), "bottomright");

	local bgTexture = CreateFrame("Frame", nil, background, "DialogBorderTemplate");

	local title = background:CreateTexture();
	title:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header");
	Anchors.Share(title, "top", 0, -12);
	Frames.WH(title, 256, 64);
	local titleText = background:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	Anchors.Share(titleText, "top", 0, 1);
	titleText:SetText("Color Swatches");

	local titleHitBox = Frames.New(background);
	Anchors.ShareAll(titleHitBox, title);
	Frames.ProxyDraggable(background, titleHitBox);
	Frames.Draggable(background);

	local swatchSize = 16;
	local startX = swatchSize*1.5;
	local cx = startX;
	local cy = swatchSize*2;
	local rowSize = #classes*2*swatchSize;
	local rowRef = nil;
	local ref = nil;
	function AddColor(c)
	   local swatch = Frames.New("Button", background);
	   Frames.WH(swatch, swatchSize);
	   if cx == startX then
		  if cy == swatchSize*2 then
			 Anchors.Share(swatch, "topleft", cx, cy);         
		  else
			 Anchors.VFlip(swatch, rowRef, "bottomleft");
		  end;
		  rowRef = swatch;
	   else
		  Anchors.HFlip(swatch, ref, "topright");
	   end;
	   ref = swatch;
	   
	   Frames.Color(swatch, c);
	   swatch:SetScript("OnClick", function()
		  background:SetColorRGB(c[1], c[2], c[3]);
          selectedColor = c;
	      background.func();
	   end);
	   cx = cx + swatchSize;
	   if cx + swatchSize > startX + rowSize + swatchSize then
		  SkipRow();
	   end;
	end;
	local maxX = 0;
	function SkipRow()
	   maxX = math.max(maxX, cx);
	   cx = startX;
	   cy = cy + swatchSize;
	end;

	local function AddPresets()
	   local vres = 25;
	   for i=1, vres-1 do
		  local v = (i-1)/(vres-1);
		  AddColor({v,v,v});
	   end;
	   SkipRow();
	   for i=1, #classes do 
		  local cc = Media.color[classes[i]];
		  AddColor(cc);
		  AddColor(Colors.Mix(cc, Media.color.black, .5));
	   end;
	   SkipRow();
	end;

	local function AddComputed()
	   local res = 6;
	   local h = 0;
	   for i = 1, res-1 do
		  for j = 1, res-1 do
			 h = 0;
			 while h < 360 do
				AddColor(Colors.HSVtoRGB({h, 1-(i-1)/(res-1), 1-(j-1)/(res-1)}));
				h = h + 15;
			 end;
			 if cx ~= 0 then
				SkipRow();
			 end;
		  end;
	   end;
	end;
	AddPresets();
	AddComputed();
	for i=0, #ITEM_QUALITY_COLORS-1 do
	   local c = ITEM_QUALITY_COLORS[i];
	   AddColor({c.r, c.g, c.b});
	end;
	SkipRow();

	local buttonHeight = 22;
	local ok = CreateFrame("Button", nil, background, "GameMenuButtonTemplate");
	ok:SetText("Okay");
	ok:SetHeight(buttonHeight);
	local cancel = CreateFrame("Button", nil, background, "GameMenuButtonTemplate");
	cancel:SetText("Cancel");
	local buttonOffset = 12;
	Anchors.Share(ok, "bottomleft", buttonOffset);
	Anchors.Share(cancel, "bottomright", buttonOffset);
	local buttonSpacing = 1;
	ok:SetPoint("right", background, "bottom", -buttonSpacing, 0);
	cancel:SetPoint("left", background, "bottom", buttonSpacing, 0);

	ok:SetScript("OnClick", function()
		background.func();
		background:Hide();
	end);

	cancel:SetScript("OnClick", function()
		background.func(background.previousValues);
		background:Hide();
	end);

	background.GetColorRGB = function()
		return unpack(selectedColor);
	end;

	background.SetColorRGB = function(self, r,g,b)
		selectedColor = {r,g,b};
	end;

	Frames.WH(background, maxX+swatchSize*1.5, cy+swatchSize+buttonHeight+4);
	background:Hide();
	return background;
end;

local ColorSwatchPanel = CreateColorSwatchPanel();

StaticPopupDialogs.HackAccept = {
    text = 'Accept new Hack page from %s?', button1 = 'Yes', button2 = 'No',
    timeout = 0, whileDead = 1, hideOnEscape = 1,
    OnAccept = function(self)
        Hack.New(self.page, true) -- all received pages start at end of list
        Remote:Send("Hack", self.sender, "Ack" .. PLAYERNAME);
    end,
    OnCancel = function(self)
        Remote:Send("Hack", self.sender, "Nack" .. PLAYERNAME);
    end,
}

local shownElems = false;

local function CloneElements(elements)
	local copied = {};
	for i=1, #elements do
		local elem = elements[i];
		local copy = {type=elem.type, name=elem.name};
		if elem.type == "text" or elem.type == "percent" then
			copy.value = elem.value;
		elseif elem.type == "color" then
			local c1 = elem.value[1];
			local c2 = elem.value[2];
			copy.value = {
				{c1[1], c1[2], c1[3]},
				{c2[1], c2[2], c2[3]},
				elem.value[3]
			};
		end;
		table.insert(copied, copy);
	end;
	return copied;
end;

StaticPopupDialogs.HackRevert = {
    text = 'Revert the selected Hack page?', button1 = 'Yes', button2 = 'No',
    timeout = 0, whileDead = 1, hideOnEscape = 1,
    OnAccept = function(self)
		local page = Hack.EditedPage();
		if not page then
			return;
		end;
		HackEditBox:SetText(Hack.revert)
		page.elements = CloneElements(Hack.revertElements);
		HackEditBox:SetCursorPosition(0)
		HackRevert:Disable()
		if shownElems then
			Hack.ShowElementsPage();
		end;
    end,
    OnCancel = function(self)
    end,
}

StaticPopupDialogs.HackSendTo = {
    text = 'Send selected page to', button1 = 'OK', button2 = 'CANCEL',
    hasEditBox = 1, timeout = 0, whileDead = 1, hideOnEscape = 1,
    OnAccept = function(self)
        --XXX local name = getglobal(this:GetParent():GetName()..'EditBox'):GetText()
        local name = self.editBox:GetText()
        if name == '' then return true end
        Hack.SendPage(self.page, 'WHISPER', name)
    end
}

StaticPopupDialogs.HackDelete = {
    text = 'Delete selected %s?', button1 = 'Yes', button2 = 'No',
    timeout = 0, whileDead = 1, hideOnEscape = 1,
    OnAccept = function()
        Hack.DeleteSelected()
    end
}

StaticPopupDialogs.HackConfirmSync = {
    text = "Accept syncs of page '%s' from %s?", button1 = 'Yes', button2 = 'No',
    timeout = 0, whileDead = 1, hideOnEscape = 1,
    OnAccept = function(self)
        Remote:Send("Hack", self.sender, "AcceptSync" .. self.page);
        Hack.AutoApproveUpdates(self.page, self.sender);
    end,
    OnCancel = function(self)
        Remote:Send("Hack", self.sender, "RefuseSync" .. self.page);
    end,
}

StaticPopupDialogs.HackNoTargetForSharing = {
    text = 'You must have a target to share this Hack script.', button1 = 'OK',
    timeout = 0, whileDead = 1, hideOnEscape = 1,
    OnAccept = function(self)
    end
}

local db -- alias for HackDB
local pages -- alias for HackDB.pages
local order -- alias for HackDB.order
local selected = nil -- index of selected list item
local autoapproved = nil
local sharing = nil

local dataPanel = nil;

local function printf(...) DEFAULT_CHAT_FRAME:AddMessage('|cffff6600<Hack>: '..format(...)) end
local function getobj(...) return getglobal(format(...)) end
local function enableButton(b,e) if e then HackNew.Enable(b) else HackNew.Disable(b) end end

-- finds the page for the index
function Hack.Find(index)
    if order[index] then
        return pages[order[index]]
    end
end

function Hack.Compile(page, undoers)
	local text = page.data:gsub('||','|');
    local func, err = loadstring(text, page.name)
    if not func then Hack.ScriptError(err) return Noop end;
	if not page.sessionData then
		local sessionData = {};
		page.sessionData = function()
			return sessionData;
		end;
	end;
	local env = {
		UNDOABLE=function(func, ...)
			if Frames.IsRegion(func) then
				func = Curry(Frames.Destroy, func);
			elseif type(func) == "table" and select("#", ...) == 0 and func.Destroy then
				func = Curry(func, "Destroy");
			else
				func = Curry(func, ...);
			end;
			table.insert(undoers, func);
		end,
		SESSION=page.sessionData()
	};
	setmetatable(env, {__index=_G});
	if page.elements then
		for i=1, #page.elements do
			local elem = page.elements[i];
			if elem.type == "text" then
				env[elem.name] = elem.value;
			elseif elem.type == "percent" then
				env[elem.name] = elem.value;
			elseif elem.type == "color" then
				env[elem.name] = Colors.Mix(elem.value[1], elem.value[2], elem.value[3]);
			end;
		end;
	end;
	setfenv(func, env);
    return func;
end

function Hack.ScriptError(err)
	printf("Script error: " .. err);
	Lists.Each({("\n"):split(debugstack(2))}, function(l)
		if #l > 0 then
			printf(l);
		end;
	end);
end;

-- find page by index or name and return it as a compiled function
function Hack.Get(name)
    local page = type(name)=='number' and Hack.Find(name) or pages[name]
    if not page then printf('attempt to get an invalid page') return end
	local undoers = {};
    local runner = Hack.Compile(page, undoers)
	return function()
		Hack.StopPage(page);
		local runnerSucc, rv = xpcall(runner, Hack.ScriptError);
		if not runnerSucc then
			rv = nil;
		end;
		if #undoers > 0 then
			page.undoer = function()
				local succ, err;
				succ = true;
				if type(rv) == "function" then
					succ, err = xpcall(rv, Hack.ScriptError);
				end;
				local i = #undoers;
				while i > 0 do
					local undoerSucc, err = xpcall(undoers[i], Hack.ScriptError);
					succ = succ and undoerSucc;
					i = i - 1;
				end;
				if not succ then
					printf("Script error while stopping");
				end;
			end;
		elseif type(rv) == "function" then
			page.undoer = rv;
		elseif runnerSucc then
			return rv;
		end;
	end;
end

-- avoids need to create a table to capture return values in Hack.Execute
local function CheckResult(...)
    if ... then return select(2,...) end
    Hack.ScriptError(select(2,...))
end

function Hack.Execute(func, ...)
    local undoer = func(...);
    -- if func then return CheckResult( pcall(func, ...) ) end
end

function Hack.EnableStartStop()
	HackStartStop:GetNormalTexture():SetTexCoord(.5, .625, .875, 1);
end;

function Hack.DisableStartStop()
	HackStartStop:GetNormalTexture():SetTexCoord(.625, .75, .875, 1);
end;

function Hack.Run(index, ...)
    local func = Hack.Get(index or selected);
	if func then
		if PROTECT_SCRIPTS and UnitAffectingCombat("player") then
			printf("Page cannot be run while player is in combat.");
			return;
		end;
		local rv = Hack.Execute(func, ...);
		local name = index;
		if not name then
			name = Hack.EditedPage().name;
		end;
		--printf("Ran page " .. name);
		if Hack.EditedPage() then
			if Hack.EditedPage().undoer then
				Hack.EnableStartStop();
			else
				Hack.DisableStartStop();
			end;
		end;
		return rv;
	end;
end

do
    -- This table is not accessed outside of Hack.Require, so we isolate it using
    -- a do...end block here.
    local loaded = {}

    -- Runs a Hack page, specified by name, only if it has not been ran before. Pages
    -- that are ran explicitly by the user are not recorded here; specifically, only
    -- explicit calls to Hack.Require or pages that are autoran will be recorded as
    -- "loaded".
    --
    -- Frito: I think this definition should change to any invocation, whether done by
    -- the user or by Hack itself. Of course, explicit runs by the user will always
    -- result in running the page; its merely the status as an ignored invocation that
    -- would change.
    function Hack.Require(name)
        if not loaded[name] then
            loaded[name] = true
            Hack.Run(name)
        end
    end
end

function Hack.DoAutorun()
	for _,pageName in ipairs(order) do
		local page = pages[pageName];
        if page.autorun then
            Hack.Require(page.name);
        end
	end;
end

function Hack.GetUniqueName(name)
    name = name:gsub("%(%d+%)$", "");
    if not pages[name] then
        return name;
    end;
    local count = 2;
    while true do
        local candidate = ("%s(%d)"):format(name, count);
        if not pages[candidate] then
            return candidate;
        end;
        count = count + 1;
    end;
end

function Hack.Copy()
	if not selected then
		return;
	end;
	local src = pages[order[selected]];
	local clone = {
		name = src.name,
		data = src.data,
		colorize = src.colorize,
		elements = {}
	};
	for i=1, #src.elements do
		local se = src.elements[i];
		table.insert(clone.elements, {
			type=se.type,
			name=se.name,
			value=se.value
		});
	end;
	Hack.New(clone, true);
end;

function Hack.OnLoad(self)
    -- instantiate list items
    local name = 'HackListItem'
    for i=2,Hack.MaxVisible do
        local li = CreateFrame('Button', name..i, HackListFrame, 'T_HackListItem')
        li:SetPoint('TOP', name..(i-1), 'BOTTOM')
        li:SetID(i)
    end

    Callbacks.PersistentValue("HackDB", function(loadedDB)
        if loadedDB == nil then
            loadedDB = HackDB;
        end;
        HackDB = loadedDB;
        db = loadedDB;
    end);
    Callbacks.PersistentValue("HackDB", Hack.VARIABLES_LOADED, self);
    Remote["Hack"](Hack.CHAT_MSG_ADDON);
    Callbacks.StringChunks(Remote["HackPages"], Hack.INCOMING_PAGE);

    Slash.hack = function(name)
        if name == '' then
            Hack.Toggle()
        else
            Hack.Run(name)
        end
    end

    printf('Loaded. /hack to toggle')
end

function Hack.VARIABLES_LOADED(self, db)
	if db == nil then
		db = HackDB;
	end;
    Hack.Upgrade(db)
    pages = db.pages
    order = db.order
    autoapproved = db.autoapproved
    sharing = db.sharing
    Hack.UpdateFont()
    Hack.UpdateButtons()
    Hack.UpdateSearchContext()
    HackSnap:SetChecked(db.snap)
    Hack.Snap()
    if not HackIndent then HackColorize:Hide() end
    self:SetMaxResize(Hack.MaxWidth, (Hack.MaxVisible * Hack.ListItemHeight) + Hack.ListVOffset + 5)
    self:SetMinResize(Hack.MinWidth, Hack.MinHeight)
    HackListFrame:SetScript('OnSizeChanged', Hack.UpdateNumListItemsVisible)
    Hack.UpdateNumListItemsVisible()
    Hack.DoAutorun()
	return function()
		return HackDB;
	end;
end

function Hack.SelectListItem(index)
    selected = index
    Hack.UpdateButtons()
    Hack.EditPage()
end

local function ListItemClickCommon(id, op)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
    op(id + FauxScrollFrame_GetOffset(HackListScrollFrame))
    Hack.UpdateListItems()
end

function Hack.OnListItemClicked(id)
    ListItemClickCommon(id, Hack.SelectListItem)
end

function Hack.OnListItemAutorunClicked(id, enable)
    ListItemClickCommon(id, function(selected) pages[order[selected]].autorun = enable end)
end

function Hack.UpdateNumListItemsVisible()
    local visible = math.floor( (HackListFrame:GetHeight()-Hack.ListVOffset) / Hack.ListItemHeight )
    Hack.NumVisible = math.min( Hack.MaxVisible, visible )
    Hack.UpdateListItems()
end

function Hack.UpdateListItems()
    local scrollFrameWidth = HackListFrame:GetWidth() - 18 -- N = inset from right edge

    FauxScrollFrame_Update(HackListScrollFrame, #order, Hack.NumVisible, Hack.ListItemHeight,
        nil, nil, nil, HackListScrollFrame, scrollFrameWidth-17, scrollFrameWidth) -- N = room for scrollbar
    local offset = FauxScrollFrame_GetOffset(HackListScrollFrame)
    for widgetIndex=1, Hack.MaxVisible do
        local itemIndex = offset + widgetIndex
        local item = pages[order[itemIndex]]
        local widget = getobj('HackListItem%d', widgetIndex)
        if not item or widgetIndex > Hack.NumVisible then
            widget:Hide()
        else
            widget:Show()
            local name = getobj('HackListItem%dName', widgetIndex)
            local edit = getobj('HackListItem%dEdit', widgetIndex)
            local auto = getobj('HackListItem%dAutorun', widgetIndex)
            edit:ClearFocus() -- in case someone tries to scroll while renaming
              if Hack.SearchMatch(item) then
                name:SetTextColor(1,1,1) else name:SetTextColor(.3,.3,.3) end
            if itemIndex == selected then
                widget:LockHighlight() else widget:UnlockHighlight() end
            auto:Show()
            name:SetText(item.name)
            auto:SetChecked(item.autorun)
        end
    end
end

-- Basically got the following from WoWLua
-- Adding Line Numbers to the EditPage
function Hack:UpdateLineNums()
    -- could edit it to pass a variable and highlight a line

    -- Since this can be FAIAP enabled, we need to pass true in order
    -- to get the raw values
    local editbox = HackEditBox
    local linebox = HackLineNumEditBoxFrame
    local linescroll = HackLineNumScrollFrame
    local linetest = HackEditBox:CreateFontString()
    linetest:SetFont(Hack.fonts[db.font], db.fontsize)

    -- The 65 accounts for text insets in the xml
    local width = editbox:GetWidth() - 65
    local text = editbox:GetText(true)

    local linetext = ""
    local count = 1
    for line in text:gmatch("([^\n]*\n?)") do
            if #line > 0 then
            -- XXX will highlight if I ever put it in
            -- linetext = linetext .. "|cFFFF1111" .. count .. "|r" .. "\n"
            linetext = linetext .. count .. "\n"
            count = count + 1

            -- Check to see if the line of text spans more than one actual line
            linetest:SetText(line:gsub("|", "||"))
            local testwidth = linetest:GetWidth()
            if testwidth >= width then
                linetext = linetext .. string.rep("\n", math.floor(testwidth / width))
            end
        end
    end
--[[
    -- XXX what is this doing?
    if text:sub(-1, -1) == "\n" then
        linetext = linetext .. count .. "\n"
        count = count + 1
    end
--]]

    -- Make the line number frame wider as necessary
    linetest:SetText(count)
    local numwidth = linetest:GetWidth()
    -- always a 3 pixel buffer between the number and the main editbox
    linescroll:SetWidth(3+numwidth)
    linebox:SetWidth(3+numwidth)

    -- apply what we've done
    linebox:SetText(linetext)
end

function Hack.UpdateButtons()
    enableButton( HackDelete,   selected )
    enableButton( HackRename,   selected )
    enableButton( HackSend,     selected )
    enableButton( HackMoveUp,   selected and selected > 1 )
    enableButton( HackMoveDown, selected and selected < #order )
end

function Hack.UpdateSearchContext()
    local pattern = HackSearchEdit:GetText()
        :gsub('[%[%]%%()]', '%%%1') -- escape magic chars (the price we pay for real-time filtering)
        :gsub('%a', function(c) return format('[%s%s]', c:lower(), c:upper()) end) -- case insensitive
    local nx, bx = HackSearchName:GetChecked(), HackSearchBody:GetChecked()
    function Hack.SearchMatch(item)
        return not (nx or bx)
        or (nx and item.name:match(pattern))-- searching names
        or (bx and item.data:match(pattern)) -- searching inside pages
    end
    Hack.UpdateListItems()
end

function Hack.DoSearch(direction) -- 1=down, -1=up
    if #order == 0 then return end
    local start = selected or 1
    local it = start
    repeat
        it = it + direction
        if      it > #order then it = 1 -- wrap at..
        elseif it < 1 then it = #order --    ..either end
        end
        if Hack.SearchMatch(order[it]) then
            Hack.SelectListItem(it)
            Hack.ScrollSelectedIntoView()
            HackSearchEdit:SetFocus()
            break
        end
    until it == start
end

function Hack.ScrollSelectedIntoView()
    local offset = FauxScrollFrame_GetOffset(HackListScrollFrame)
    local id = selected - offset
    if      id >  Hack.NumVisible then offset = selected-Hack.NumVisible
    elseif id <= 0                     then offset = selected-1 end
    FauxScrollFrame_SetOffset(HackListScrollFrame, offset)
    HackListScrollFrameScrollBar:SetValue(offset * Hack.ListItemHeight)
    Hack.UpdateListItems()
end

function Hack.Toggle(msg)
    if HackListFrame:IsVisible() then
        HackListFrame:Hide()
    else
        HackListFrame:Show()
    end
end

function Hack.Tooltip(self)
    local which = self:GetName()
    local tip
    if which and which:match('Autorun') then
        tip = 'Automatically run this page when Hack loads'
    elseif Hack.tooltips[which] then
        tip = format(Hack.tooltips[which], "page")
    else
        return;
    end;
    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    GameTooltip:AddLine(tip)
    GameTooltip:Show()
end


function Hack.Rename()
    local id = selected - FauxScrollFrame_GetOffset(HackListScrollFrame)
    local name = getobj("HackListItem%dName", id)
    local edit = getobj("HackListItem%dEdit", id)
    edit:SetText( pages[order[selected]].name )
    edit:Show()
    edit:SetCursorPosition(0)
    edit:SetFocus()
    name:Hide()
end

function Hack.FinishRename(name, editbox)
    name = Hack.GetUniqueName(name)
    pages[name] = pages[order[selected]]
    pages[name].name = name
    pages[order[selected]] = nil  --its happening
    order[selected] = name
    Hack.UpdateListItems()
end

function Hack.New(page, atEnd)
    local index = (atEnd and #order+1) or  selected and selected+1 or #order+1
    if page then
        page.name = Hack.GetUniqueName(page.name)
    else
        page = {name = Hack.GetUniqueName(''), data='' }
    end

    pages[page.name] = page
    table.insert(order, index, page.name)
    pages[page.name].index = #order

    Hack.SelectListItem(index)
    Hack.UpdateListItems()
    Hack.ScrollSelectedIntoView()
    if HackListFrame:IsShown() then Hack.Rename() end
end

function Hack.Delete()
    if IsShiftKeyDown() or #pages[order[selected]].data == 0 then
        Hack.DeleteSelected()
    else
        StaticPopup_Show('HackDelete', "page")
    end
end

function Hack.DeleteSelected()
    HackEditFrame:Hide()
    pages[order[selected]] = nil
    table.remove(order,selected)
    if #order == 0 then selected = nil
    elseif selected > #order then selected = #order end
    Hack.UpdateButtons()
    Hack.UpdateListItems()
end

function Hack.Revert()
	StaticPopup_Show('HackRevert');
end

function Hack.MoveItem(direction)
    local to = selected + direction * (IsShiftKeyDown() and 5 or 1)
    if      to > #order then to = #order
    elseif to < 1        then to = 1        end
    while selected ~= to do
        order[selected], order[selected+direction] = order[selected+direction], order[selected]
        selected = selected + direction
    end
    for i=1,#order do
        pages[order[i]].index = i --updating the index property of the pages
    end
    Hack.ScrollSelectedIntoView()
    Hack.UpdateButtons()
end

function Hack.MoveUp()
    Hack.MoveItem(-1)
end

function Hack.MoveDown()
    Hack.MoveItem(1)
end

function Hack.FontBigger()
    db.fontsize = db.fontsize + 5
    Hack.UpdateFont()
end

function Hack.FontSmaller()
    db.fontsize = db.fontsize - 5
    Hack.UpdateFont()
end

function Hack.FontCycle()
    db.font = (db.font < #Hack.fonts) and (db.font + 1) or (1)
    Hack.UpdateFont()
end
-- currently unattached to any in-game config
function Hack.ColorTableCycle()
    db.colorTable = (db.colorTable < #Hack.colorTables) and (db.colorTable+1) or (1)
    Hack.ApplyColor(true)
end

function Hack.UpdateFont()
    HackEditBox:SetFont(Hack.fonts[db.font], db.fontsize)
    HackLineNumEditBoxFrame:SetFont(Hack.fonts[db.font], db.fontsize)
end

function Hack.OnButtonClick(name)
    trace("Hack button clicked: " .. (name or ""));
    Hack[ name:match('Hack(.*)') ]()
end

function Hack.ApplyColor(colorize)
    if colorize then
        HackIndent.enable(HackEditBox,Hack.colorTables[db.colorTable], 3)
        HackIndent.colorCodeEditbox(HackEditBox)
    else
        HackIndent.disable(HackEditBox)
    end
end

function Hack.EditedPage()
     return Hack.editedPage;
end;

function Hack.EditPage()
    local page = pages[order[selected]]
    Hack.editedPage = page;
    Hack.revert = page.data
	if page.elements then
		Hack.revertElements = CloneElements(page.elements);
	else
		Hack.revertElements = {};
	end;
    HackEditBox:SetText(page.data)
    HackRevert:Disable()
    HackEditFrame:Show()
    HackEditBox:SetCursorPosition(0)
	if Hack.editedPage.undoer then
		Hack.EnableStartStop();
	else
		Hack.DisableStartStop();
	end;
    if HackIndent then
        HackColorize:SetChecked(page.colorize)
        Hack.ApplyColor(page.colorize)
    end
	if shownElems then
		Hack.ShowElementsPage();
	else
		Hack.ShowCodePage();
	end;
end

function Hack.SendPageToWatchers(page)
    if not page then
        page=Hack.EditedPage();
    end;
    if not page then
        return;
    end;
    for watcher,v in pairs(sharing[page.name]) do
		if v == SYNC_ACCEPTED then
			--printf("Syncing %s with %s", page.name, watcher);
			Hack.SendPage(page, "WHISPER", watcher);
		end;
    end;
end;

local shareMyPage=Timing.Cooldown(.25, Hack.SendPageToWatchers);
function Hack.OnEditorTextChanged(self, isUserInput)
    local page = pages[order[selected]]
    page.data = self:GetText()
    enableButton(HackRevert, page.data ~= Hack.revert)
    if not HackEditScrollFrameScrollBarThumbTexture:IsVisible() then
        HackEditScrollFrameScrollBar:Hide()
    end
    Hack.UpdateLineNums();
    if isUserInput and sharing[page.name] then
        shareMyPage();
    end;
end

function Hack.RefreshText()
	local orig = Hack.EditedPage().data;
	local cur = HackEditBox:GetText();
	if(orig ~= cur) then
		Hack.OnEditorTextChanged(HackEditBox, true);
	end;
end;

function Hack.OnEditorShow()
    Hack.MakeESCable('HackListFrame',false)
    PlaySound(SOUNDKIT.IG_QUEST_LIST_OPEN);
	Hack.ShowingEditor = Timing.Periodic("400ms", Hack.RefreshText);
end

function Hack.DestroyElementsPanel()
	if not dataPanel then return end;
	refreshElementsPage = nil;
	shownElems = false;
	Frames.Destroy(dataPanel);
end;

function Hack.OnEditorHide()
    Hack.MakeESCable('HackListFrame',true)
    PlaySound(SOUNDKIT.IG_QUEST_LIST_CLOSE);
	if(Hack.ShowingEditor) then
		Hack.RefreshText();
		Hack.ShowingEditor();
		Hack.ShowingEditor = nil;
	end;
	Hack.DestroyElementsPanel();
end

function Hack.OnEditorLoad(self)
    table.insert(UISpecialFrames,'HackEditFrame')
    self:SetMinResize(Hack.MinEditWidth,Hack.MinHeight)
	ScrollingEdit_OnLoad(HackEditBox);
	Hack.DisableStartStop();
    HackEditBox:SetScript("OnTextChanged", function(self, isUserInput)
        ScrollingEdit_OnTextChanged(self, self:GetParent())
        Hack.OnEditorTextChanged(self, isUserInput)
    end);
    HackEditBox:SetScript("OnCursorChanged", function(self, x, y, w, h)
        ScrollingEdit_OnCursorChanged(self, x, y, w, h);
	end);
end

function Hack.OnEditorResized()
	HackEditBox:SetWidth(HackEditFrame:GetWidth());
	if refreshElementsPage then
		refreshElementsPage();
	end;
end;

function Hack.Snap()
    HackDB.snap = HackSnap:GetChecked()
    if HackDB.snap then
        HackEditFrame:ClearAllPoints()
        HackEditFrame:SetPoint('TOPLEFT', HackListFrame, 'TOPRIGHT', -2, 0)
    end
end

function Hack.Colorize()
    local page = pages[order[selected]]
    page.colorize = HackColorize:GetChecked()
    Hack.ApplyColor(page.colorize)
end

function Hack.SelectedPage()
     return pages[order[selected]];
end;

do
    local function send(self) Hack.SendPage(Hack.SelectedPage(), self.value) end
    local menu = {
        { text = 'Player', func = function()
                local dialog = StaticPopup_Show('HackSendTo')
                if dialog then
                    dialog.page = pages[order[selected]]
                    dialog.editBox:SetScript('OnEnterPressed',  function(t) dialog.button1:Click() end)
                end
            end
        },
        { text = 'Party', func = send },
        { text = 'Raid',  func = send },
        { text = 'Guild', func = send },
    }
    CreateFrame('Frame', 'HackSendMenu', HackListFrame, 'UIDropDownMenuTemplate')
    function Hack.Send()
        menu[2].disabled = not UnitInParty("player")
        menu[3].disabled = not UnitInRaid('player')
        menu[4].disabled = not IsInGuild()
        EasyMenu(menu, HackSendMenu, 'cursor', nil, nil, 'MENU')
    end
end

local i=0;
function Hack.SendPage(page, channel, name)
	if not sharing[page.name] or sharing[page.name][name or channel] ~= SYNC_ACCEPTED then
		printf("Sending '%s' to %s", page.name, name or channel);
	end;
    Remote:Send("HackPages", name or channel,
        Serializers.WriteStringChunks(
            Serializers.WriteData(page), "HackPages")
    );
end

function Hack.StopPage(page)
	if not page then
		page = Hack.EditedPage();
	end;
	if not page.undoer then
		return false;
	end;
	page.undoer();
	page.undoer = nil;
	--printf("Stopped " .. page.name);
	Hack.DisableStartStop();
	return true;
end;

function Hack.ShowCodePage()
	local codeFrames = {
		HackFontCycle,
		HackLineNumScrollFrame,
		HackEditScrollFrame,
		HackFontBigger,
		HackFontSmaller,
		HackColorize
	};
	--printf("Showing code");
	Hack.DestroyElementsPanel();
	for i=1,#codeFrames do
		codeFrames[i]:Show();
	end;
end;

local widgetFont = "arial";

local unselectedColor = .1;

local TextWidget = OOP.Class();
function TextWidget:Constructor(parent, elem)
	local wrapper = Frames.New(parent);
	local f = Frames.Text(parent, widgetFont, 14);
	f:SetText("Name:");
	self.nameLabel = f;

	local tbg = Frames.New(parent);
	self.nameField = tbg;
	tbg:SetBackdrop({
		bgFile = nil,
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
		tile = true, tileSize = 16, edgeSize = 8, 
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
		backdropColor = { r=0, g=0, b=0, a=1 }
	});
	tbg:SetHeight(20);
	Anchors.HFlip(tbg, f, "topright", 3, 3);
	Anchors.Share(tbg, parent, "right", 3);

	local eb = Frames.New("EditBox", tbg);
	Anchors.ShareAll(eb);
	eb:SetText(elem.name or "");
	eb:SetAutoFocus(false);
	eb:SetFontObject(GameFontNormal);
	eb:SetScript("OnEscapePressed", Seal(eb, "ClearFocus"));
	eb:SetScript("OnTextChanged", function()
		elem.name = eb:GetText();
		Hack.RefreshElements();
	end);

	local vf = Frames.Text(parent, widgetFont, 14);
	vf:SetText("Text:");
	self.valueLabel = vf;

	Anchors.VFlip(vf, f, "bottomleft", 6);

	local vbg = Frames.New(parent);
	self.valueField = vbg;
	vbg:SetBackdrop({
		bgFile = nil,
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
		tile = true, tileSize = 16, edgeSize = 8, 
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
		backdropColor = { r=0, g=0, b=0, a=1 }
	});
	vbg:SetHeight(20);
	Anchors.HFlip(vbg, vf, "topright", 3, 3);
	Anchors.Share(vbg, parent, "right", 3);
	self.valueField = vbg;

	local vb = Frames.New("EditBox", vbg);
	Anchors.ShareAll(vb);
	vb:SetAutoFocus(false);
	vb:SetFontObject(GameFontNormal);
	vb:SetScript("OnEscapePressed", Seal(vb, "ClearFocus"));
	vb:SetText(elem.value or "");
	vb:SetScript("OnTextChanged", function()
		elem.value = vb:GetText();
		Hack.RefreshElements();
	end);

	Anchors.Share(wrapper, f, "topleft");
	Anchors.Share(wrapper, vbg, "bottomright");
	self.wrapper = wrapper;

	self.selector = CreateFrame("Button", nil, parent);
	self.selector:SetBackdrop({
		bgFile = nil,
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
		tile = true, tileSize = 16, edgeSize = 8, 
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
		backdropColor = { r=0, g=0, b=0, a=1 }
	});
	self.selector:SetWidth(14);
	Frames.Color(self.selector, unselectedColor);
	Anchors.HFlip(self.selector, wrapper, "topleft", 2, 4);
	Anchors.HFlip(self.selector, wrapper, "bottomleft", 2, 4);
end;

function TextWidget:Selector()
   return self.selector;
end;

function TextWidget:Bounds()
   return self.wrapper;
end;

function TextWidget:Anchor(anchor)
   if anchor:lower() == "top" then
      return self.nameLabel;
   end;
end;

function TextWidget:Show()
	self.selector:Show();
	self.nameLabel:Show();
	self.nameField:Show();
	self.valueLabel:Show();
	self.valueField:Show();
end;

function TextWidget:Hide()
	self.selector:Hide();
	self.nameField:Hide();
	self.nameLabel:Hide();
	self.valueLabel:Hide();
	self.valueField:Hide();
end;

local PercentWidget = OOP.Class();
function PercentWidget:Constructor(parent, elem)
	local wrapper = Frames.New(parent);
	local f = Frames.Text(parent, widgetFont, 14);
	f:SetText("Name:");
	self.nameLabel = f;

	local tbg = Frames.New(parent);
	self.nameField = tbg;
	tbg:SetBackdrop({
		bgFile = nil,
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
		tile = true, tileSize = 16, edgeSize = 8, 
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
		backdropColor = { r=0, g=0, b=0, a=1 }
	});
	tbg:SetHeight(20);
	Anchors.HFlip(tbg, f, "topright", 3, 3);
	Anchors.Share(tbg, parent, "right", 3);

	local eb = Frames.New("EditBox", tbg);
	Anchors.ShareAll(eb);
	eb:SetText(elem.name or "");
	eb:SetAutoFocus(false);
	eb:SetFontObject(GameFontNormal);
	eb:SetScript("OnEscapePressed", Seal(eb, "ClearFocus"));
	eb:SetScript("OnTextChanged", function()
		elem.name = eb:GetText();
		Hack.RefreshElements();
	end);

	local vf = Frames.Text(parent, widgetFont, 14);
	vf:SetText("Percent:");
	self.valueLabel = vf;

	Anchors.VFlip(vf, f, "bottomleft", 6);

	local scroller = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate");
	scroller:SetOrientation("HORIZONTAL");
	Anchors.HFlip(scroller, vf, "right", 4);
	Anchors.Share(scroller, parent, "right", 7);
	scroller:SetHeight(16);
	scroller:SetMinMaxValues(0, 1);
	if elem.value == nil then
		elem.value = 0.5;
	end;
	scroller:SetValue(elem.value);
	scroller:SetScript("OnValueChanged", function()
		elem.value = scroller:GetValue();
		Hack.RefreshElements();
	end);
	self.scroller = scroller;

	Anchors.Share(wrapper, f, "topleft");
	Anchors.Share(wrapper, scroller, "bottomright", -2, -12);
	self.wrapper = wrapper;

	self.selector = CreateFrame("Button", nil, parent);
	self.selector:SetBackdrop({
		bgFile = nil,
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
		tile = true, tileSize = 16, edgeSize = 8, 
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
		backdropColor = { r=0, g=0, b=0, a=1 }
	});
	self.selector:SetWidth(14);
	Frames.Color(self.selector, unselectedColor);
	Anchors.HFlip(self.selector, wrapper, "topleft", 2, 4);
	Anchors.HFlip(self.selector, wrapper, "bottomleft", 2, 4);
end;

function PercentWidget:Bounds()
   return self.wrapper;
end;

function PercentWidget:Selector()
   return self.selector;
end;

function PercentWidget:Anchor(anchor)
   if anchor:lower() == "top" then
      return self.nameLabel;
   end;
end;

function PercentWidget:Show()
	self.selector:Show();
	self.nameLabel:Show();
	self.nameField:Show();
	self.valueLabel:Show();
	self.scroller:Show();
end;

function PercentWidget:Hide()
	self.selector:Hide();
	self.nameLabel:Hide();
	self.nameField:Hide();
	self.valueLabel:Hide();
	self.scroller:Hide();
end;

local ColorWidget = OOP.Class();
function ColorWidget:Constructor(parent, elem)
	local wrapper = Frames.New(parent);
	local f = Frames.Text(parent, widgetFont, 14);
	f:SetText("Name:");
	self.nameLabel = f;

	local tbg = Frames.New(parent);
	self.nameField = tbg;
	tbg:SetBackdrop({
		bgFile = nil,
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
		tile = true, tileSize = 16, edgeSize = 8, 
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
		backdropColor = { r=0, g=0, b=0, a=1 }
	});
	tbg:SetHeight(20);
	Anchors.HFlip(tbg, f, "topright", 3, 3);
	Anchors.Share(tbg, parent, "right", 3);

	local eb = Frames.New("EditBox", tbg);
	Anchors.ShareAll(eb);
	eb:SetText(elem.name or "");
	eb:SetAutoFocus(false);
	eb:SetFontObject(GameFontNormal);
	eb:SetScript("OnEscapePressed", Seal(eb, "ClearFocus"));
	eb:SetScript("OnTextChanged", function()
		elem.name = eb:GetText();
		Hack.RefreshElements();
	end);

	local vf = Frames.Text(parent, widgetFont, 14);
	vf:SetText("Color:");
	self.valueLabel = vf;

	Anchors.VFlip(vf, f, "bottomleft", 6);
	local colorSize = 24;

	local function ShowColorPicker(r, g, b, changedCallback)
		ColorPickerFrame.func, ColorPickerFrame.cancelFunc = changedCallback, changedCallback;
		ColorPickerFrame.hasOpacity = false;
		ColorPickerFrame.previousValues = {r,g,b};
		ColorPickerFrame:SetColorRGB(r,g,b);
		ColorPickerFrame:Hide(); -- Need to run the OnShow handler.
		ColorPickerFrame:Show();
	end

	local colorIndex = 1;
	local function MakeColor(c)
		local bg = CreateFrame("Button", "ColorSwatch" .. colorIndex, parent);
		local bgc = 0.1;
		local inset = 4;
		bg:SetBackdrop({
			bgFile = nil,
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
			tile = true, tileSize = 16, edgeSize = 8, 
			insets = { left = inset, right = inset, top = inset, bottom = inset },
			backdropColor = { r=bgc, g=bgc, b=bgc, a=1 }
		});
		Frames.WH(bg, 32);

		local f = Frames.New(bg);
		bg:SetScript("OnClick", function()
			EasyMenu({
				{text="Color Picker", func=function()
					ShowColorPicker(c[1], c[2], c[3], function(restore)
						local newc;
						if restore then
							newc = restore;
						else
							local r, g, b = ColorPickerFrame:GetColorRGB();
							newc = {r,g,b};
						end;
						c[1] = newc[1];
						c[2] = newc[2];
						c[3] = newc[3];
						Frames.Color(f, c);
						Hack.RefreshElements();
					end);
				end},
				{text="Swatches", func=function()
					local changedCallback = function(restore)
						local newc;
						if restore then
							newc = restore;
						else
							newc = {ColorSwatchPanel:GetColorRGB()};
						end;
						c[1] = newc[1];
						c[2] = newc[2];
						c[3] = newc[3];
						Frames.Color(f, c);
						Hack.RefreshElements();
					end;
					ColorSwatchPanel.func, ColorSwatchPanel.cancelFunc = changedCallback, changedCallback;
					ColorSwatchPanel.previousValues = {c[1], c[2], c[3]};
					ColorSwatchPanel:Show();
				end},
				{text="Cancel", func=function()
				end},
			}, bg, "cursor");
		end);

		Anchors.ShareAll(f);
		Frames.Color(f, c);
		return bg;
	end;
	self.firstColor = MakeColor(elem.value[1]);
	Anchors.HFlip(self.firstColor, vf, "topright", 4);
	self.secondColor = MakeColor(elem.value[2]);
	Anchors.Share(self.secondColor, vf, "top");
	Anchors.Share(self.secondColor, parent, "right", 3);

	local scroller = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate");
	scroller:SetOrientation("HORIZONTAL");
	Anchors.HFlip(scroller, self.firstColor, "right", 4);
	Anchors.HFlip(scroller, self.secondColor, "left", 4);
	scroller:SetHeight(16);
	scroller:SetMinMaxValues(0, 1);
	if elem.value == nil then
		elem.value = 0.5;
	end;
	scroller:SetValue(elem.value[3]);
	scroller:SetScript("OnValueChanged", function()
		elem.value[3] = scroller:GetValue();
		Hack.RefreshElements();
	end);
	self.scroller = scroller;

	Anchors.Share(wrapper, f, "topleft");
	Anchors.Share(wrapper, self.secondColor, "bottomright", 0, -8);
	self.wrapper = wrapper;

	self.selector = CreateFrame("Button", nil, parent);
	self.selector:SetBackdrop({
		bgFile = nil,
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
		tile = true, tileSize = 16, edgeSize = 8, 
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
		backdropColor = { r=0, g=0, b=0, a=1 }
	});
	self.selector:SetWidth(14);
	Frames.Color(self.selector, unselectedColor);
	Anchors.HFlip(self.selector, wrapper, "topleft", 2, 4);
	Anchors.HFlip(self.selector, wrapper, "bottomleft", 2, 4);
end;

function ColorWidget:Bounds()
   return self.wrapper;
end;

function ColorWidget:Selector()
   return self.selector;
end;

function ColorWidget:Anchor(anchor)
	if anchor:lower() == "top" then
		return self.nameLabel;
	end;
end;

function ColorWidget:Show()
	self.selector:Show();
	self.nameLabel:Show();
	self.nameField:Show();
	self.valueLabel:Show();
	self.scroller:Show();
	self.firstColor:Show();
	self.secondColor:Show();
end;

function ColorWidget:Hide()
	self.selector:Hide();
	self.nameLabel:Hide();
	self.nameField:Hide();
	self.valueLabel:Hide();
	self.scroller:Hide();
	self.firstColor:Hide();
	self.secondColor:Hide();
end;

function Hack.RefreshElements()
	local page = Hack.EditedPage();
	HackRevert:Disable()
	if page.elements and Hack.revertElements and #page.elements == #Hack.revertElements then
		for i=1, #page.elements do
			local orig = Hack.revertElements[i];
			local elem = page.elements[i];
			if elem.type ~= orig.type then
				--print("Type changed");
				HackRevert:Enable()
				break;
			end;
			if elem.name ~= orig.name then
				--print("Name changed");
				HackRevert:Enable()
				break;
			end;
			if elem.type == "color" then
				if elem.value[3] ~= orig.value[3] then
					--print("Lerp changed");
					HackRevert:Enable()
					break;
				end;
				local c1 = elem.value[1];
				local c2 = elem.value[2];
				local o1 = orig.value[1];
				local o2 = orig.value[2];
				if c1[1] ~= o1[1] or c1[2] ~= o1[2] or c1[3] ~= o1[3] then
					--print("First color changed");
					HackRevert:Enable()
					break;
				end;
				if c2[1] ~= o2[1] or c2[2] ~= o2[2] or c2[3] ~= o2[3] then
					--print("Second color changed");
					HackRevert:Enable()
					break;
				end;
			elseif elem.value ~= orig.value then
				--print("Primitive value changed");
				HackRevert:Enable()
				break;
			end;
		end;
	else
		--print("Number of elements changed " .. #Hack.revertElements .. " versus " .. #page.elements);
		HackRevert:Enable()
	end;
	if Hack.StopPage() then
		Hack.Run();
	end;
end;

function Hack.ShowElementsPage()
	local codeFrames = {
		HackFontCycle,
		HackLineNumScrollFrame,
		HackEditScrollFrame,
		HackFontBigger,
		HackFontSmaller,
		HackColorize
	};
	--printf("Showing data");
	for i=1,#codeFrames do
		codeFrames[i]:Hide();
	end;
	shownElems = true;

	if dataPanel then
		Frames.Destroy(dataPanel);
	end;
	dataPanel = Frames.New(HackEditFrame);
	Anchors.Share(dataPanel, "topleft", 5, 24);

	local widgets = {};

	local page = Hack.EditedPage();
	if not page.elements then
		page.elements = {};
	end;

	local topSpacing = 8;
	local spacing = 12;

	local widgetSelection = Frames.New(dataPanel);
	--widgetSelection:SetFrameStrata("DIALOG");
	Frames.Color(widgetSelection, "white", .3);
	local selectedWidget = nil;

	local function Update(start)
		if selectedWidget then
			Frames.Color(selectedWidget:Selector(), unselectedColor);
			widgetSelection:Hide();
		end;
		selectedWidget = nil;
		for i=1, #widgets do
			local widget = widgets[i];
			widget:Hide();
			Anchors.Clear(widget:Anchor("top"));
		end;
		local topForm = nil;
		local totalHeight = topSpacing;
		local leftSpacing = 16;
		for i=start, #widgets do
			local widget = widgets[i];
			if topForm then
				Anchors.VFlip(widget:Anchor("top"), topForm, "bottomleft", 0, spacing);
				totalHeight = totalHeight + spacing;
			else
				Anchors.Share(widget:Anchor("top"), dataPanel, "topleft", leftSpacing, topSpacing);
			end;
			if widget:Bounds():GetHeight() + totalHeight > dataPanel:GetHeight() then
				return;
			end;
			widget:Show();
			topForm = widget:Bounds();
			totalHeight = totalHeight + topForm:GetHeight();
		end;
	end;

	local button = CreateFrame("Button", nil, dataPanel, "UIPanelButtonTemplate");
	Frames.WH(button, 150, 32);
	Anchors.Share(button, HackEditFrame, "bottomleft", 5, 9);
	button:SetText("Add New Element");
	Anchors.Share(dataPanel, "right", 24);
	Anchors.Share(dataPanel, "bottom", 40);

	local function FindSelectedElement()
		if not selectedWidget then
			return;
		end;
		for i=1, #widgets do
			if widgets[i] == selectedWidget then
				return i;
			end;
		end;
	end;

	local scroller;

	local moveUpButton = CreateFrame("Button", nil, dataPanel, "UIPanelButtonTemplate");
	Frames.WH(moveUpButton, 110, 32);
	moveUpButton:SetText("Move Up");
	moveUpButton:SetScript("OnClick", function()
		local selectedIndex = FindSelectedElement();
		if not selectedIndex then return end;
		if selectedIndex == 1 then return end;
		local elem = page.elements[selectedIndex];
		table.remove(page.elements, selectedIndex);
		table.remove(widgets, selectedIndex);
		table.insert(page.elements, selectedIndex - 1, elem);
		table.insert(widgets, selectedIndex - 1, selectedWidget);
		local widget = selectedWidget;
		Update(scroller:GetValue());   
		selectedWidget = widget;
		Frames.Color(widget:Selector(), "white");
		Anchors.Share(widgetSelection, widget:Bounds(), "topleft", -2, -4);
		Anchors.Share(widgetSelection, widget:Bounds(), "bottomright", -4, -4);
		widgetSelection:Show();
		Hack.RefreshElements();
	end);
	Anchors.HFlip(moveUpButton, button, "right", 2);

	local moveDownButton = CreateFrame("Button", nil, dataPanel, "UIPanelButtonTemplate");
	Frames.WH(moveDownButton, 110, 32);
	moveDownButton:SetText("Move Down");
	moveDownButton:SetScript("OnClick", function()
		local selectedIndex = FindSelectedElement();
		if not selectedIndex then return end;
		if selectedIndex == #widgets then return end;
		local elem = page.elements[selectedIndex];
		table.remove(page.elements, selectedIndex);
		table.remove(widgets, selectedIndex);
		table.insert(page.elements, selectedIndex + 1, elem);
		table.insert(widgets, selectedIndex + 1, selectedWidget);
		local widget = selectedWidget;
		Update(scroller:GetValue());   
		selectedWidget = widget;
		Frames.Color(widget:Selector(), "white");
		Anchors.Share(widgetSelection, widget:Bounds(), "topleft", -2, -4);
		Anchors.Share(widgetSelection, widget:Bounds(), "bottomright", -4, -4);
		widgetSelection:Show();
		Hack.RefreshElements();
	end);
	Anchors.HFlip(moveDownButton, moveUpButton, "right", 2);

	local deleteButton = CreateFrame("Button", nil, dataPanel, "UIPanelButtonTemplate");
	Frames.WH(deleteButton, 100, 32);
	deleteButton:SetText("Delete");
	deleteButton:SetScript("OnClick", function()
		local selectedIndex = FindSelectedElement();
		if not selectedIndex then return end;
		table.remove(page.elements, selectedIndex);
		table.remove(widgets, selectedIndex);
		selectedWidget:Hide();
		Update(scroller:GetValue());   
		if selectedIndex > #widgets then selectedIndex = #widgets; end;
		if selectedIndex == 0 then return end;
		widget = widgets[selectedIndex];
		Frames.Color(widget:Selector(), "white");
		Anchors.Share(widgetSelection, widget:Bounds(), "topleft", -2, -4);
		Anchors.Share(widgetSelection, widget:Bounds(), "bottomright", -4, -4);
		widgetSelection:Show();
		selectedWidget = widget;
		Hack.RefreshElements();
	end);
	Anchors.Share(deleteButton, HackEditFrame, "bottomright", 5, 9);

	dataPanel.SetVerticalScroll = function(self, start)
		Update(start);
	end;

	scroller = CreateFrame("Slider", nil, dataPanel, "UIPanelScrollBarTemplate");

	local function CalculateBottom()
		if selectedWidget then
			Frames.Color(selectedWidget:Selector(), unselectedColor);
			widgetSelection:Hide();
		end;
		selectedWidget = nil;
		for i=1, #widgets do
			local widget = widgets[i];
			widget:Hide();
			Anchors.Clear(widget:Anchor("top"));
		end;
		local topForm = nil;
		local totalHeight = topSpacing;
		local leftSpacing = 16;
		for i=1, #widgets do
			local widget = widgets[1 + #widgets - i];
			if topForm then
				Anchors.VFlip(widget:Anchor("top"), topForm, "bottomleft", 0, spacing);
				totalHeight = totalHeight + spacing;
			else
				Anchors.Share(widget:Anchor("top"), dataPanel, "topleft", leftSpacing, topSpacing);
			end;
			if widget:Bounds():GetHeight() + totalHeight > dataPanel:GetHeight() then
				scroller:Show();			
				Anchors.Share(dataPanel, "right", 24);
				return 2 + #widgets - i;
			end;
			topForm = widget:Bounds();
			totalHeight = totalHeight + topForm:GetHeight();
		end;
		scroller:Hide();			
		Anchors.Share(dataPanel, "right", 4);
		return 1;
	end;

	local bottom = CalculateBottom();

	local function InsertWidget(widget)
	   table.insert(widgets, widget);
	   local atBottom = bottom == scroller:GetValue();
	   local oldBottom = bottom;
	   bottom = CalculateBottom();
	   scroller:SetMinMaxValues(1, bottom);
	   if atBottom then
		  scroller:SetValue(bottom);
		  if oldBottom == bottom then
			 Update(bottom);
		  end;
	   else
		  Update(scroller:GetValue());   
	   end;
		widgetSelection:Hide();
		local selector = widget:Selector();
		if selector then
			selector:SetScript("OnClick", function()
				Anchors.Clear(widgetSelection);
				if widget == selectedWidget then
					Frames.Color(selector, unselectedColor);
					widgetSelection:Hide();
					selectedWidget = nil;
					return;
				end;
				if selectedWidget then
					Frames.Color(selectedWidget:Selector(), unselectedColor);
				end;
				selectedWidget = widget;
				Frames.Color(selector, "white");
				Anchors.Share(widgetSelection, widget:Bounds(), "topleft", -2, -4);
				Anchors.Share(widgetSelection, widget:Bounds(), "bottomright", -4, -4);
				widgetSelection:Show();
			end);
		end;
	end;

	button:SetScript("OnClick", function()
		EasyMenu({
			{text="Text", func=function()
				local elem = {type="text"};
				table.insert(page.elements, elem);
				InsertWidget(TextWidget:New(dataPanel, elem));
			end},
			{text="Percent", func=function()
				local elem = {type="percent"};
				table.insert(page.elements, elem);
				InsertWidget(PercentWidget:New(dataPanel, elem));
			end},
			{text="Color", func=function()
				local elem = {type="color", value={
					{0, 0, 0},
					{1, 1, 1},
					0.5
				}};
				table.insert(page.elements, elem);
				InsertWidget(ColorWidget:New(dataPanel, elem));
			end},
			{text="Cancel", func=function()
			end},
		}, button);
	end);

	Anchors.HFlip(scroller, dataPanel, "topright", 1, -17);
	Anchors.HFlip(scroller, dataPanel, "bottomright", 1, -16);
	scroller:SetMinMaxValues(1, bottom);
	scroller:SetValue(1);
	scroller:SetValueStep(1);
	scroller:SetStepsPerPage(1);
	scroller:SetObeyStepOnDrag(true);

	dataPanel:SetScript("OnMouseWheel", function(self, d)
		  d = -d;
		  if scroller:GetValue() + d < 1 then
			 scroller:SetValue(1);
		  elseif scroller:GetValue() + d > bottom then
			 scroller:SetValue(bottom)
		  else
			 scroller:SetValue(scroller:GetValue() + d);         
		  end;
	end);

	refreshElementsPage = function()
		if not dataPanel then return end;
		bottom = CalculateBottom();
		scroller:SetMinMaxValues(1, bottom);
		Update(scroller:GetValue());
	end;

	for i=1, #page.elements do
		local elem = page.elements[i];
		if elem.type == "text" then
			InsertWidget(TextWidget:New(dataPanel, elem));
		elseif elem.type == "percent" then
			InsertWidget(PercentWidget:New(dataPanel, elem));
		elseif elem.type == "color" then
			if type(elem.value) == "number" then
				elem.value = {{0, 0, 0}, {1,1,1}, 0.5};
			end;
			InsertWidget(ColorWidget:New(dataPanel, elem));
		end;
	end;
end;

function Hack.StartStop()
	if PROTECT_SCRIPTS and UnitAffectingCombat("player") then
		printf("Page cannot be stopped while player is in combat.");
		return;
	end;
	if not Hack.StopPage() then
		Hack.Run();
	end;
end;

function Hack.CHAT_MSG_ADDON(msg, sender, medium)
    if sender == PLAYERNAME then return end

    local responders = {};
    function responders.Ack()
        printf('%s accepted your page.', sender)
    end;
    function responders.Nack()
        printf('%s rejected your page.', sender)
    end;
    function responders.Share(body)
        printf('Received %s from %s', body, sender);
        local dialog=StaticPopup_Show('HackAcceptShare', body, sender);
        dialog.page=body;
        dialog.sender=sender;
    end;
    function responders.Sync(pageName)
        local dialog=StaticPopup_Show('HackConfirmSync', pageName, sender);
        dialog.page=pageName;
        dialog.sender=sender;
    end;
    function responders.AcceptSync(pageName)
		if not sharing[pageName] or sharing[pageName][sender] ~= SYNC_ACCEPTING then
			-- People could "steal" pages if we didn't record what _we_ want to send, so
			-- ignore unexpected accepts.
			return;
		end;
        sharing[pageName][sender]=SYNC_ACCEPTED;
		Hack.SendPage(pages[pageName], "WHISPER", sender);
   		printf("%s is now syncing the page '%s' with you.", sender, pageName);
    end;
    function responders.RefuseSync(pageName)
		if not sharing[pageName] or sharing[pageName][sender] ~= SYNC_ACCEPTING then
			-- People could "steal" pages if we didn't record what _we_ want to send, so
			-- ignore unexpected accepts.
			return;
		end;
   		printf("%s declined to sync this page.", sender);
    end;

    for cmd, handler in pairs(responders) do
        if Strings.StartsWith(msg, cmd) then
            handler(msg:match("^"..cmd.."(.*)$"));
            return;
        end;
    end;
    print("Message Not handled: " .. msg);
end;

function Hack.INCOMING_PAGE(msg, sender, medium)
    trace("Received page %q", msg);
    local page = Serializers.ReadData(msg);
    assert(page, "Received page must not be falsy (type was "..type(page)..")");
    assert(type(page) == "table", "Received page must be a table, but received ".. type(page));
    if autoapproved[page.name] and autoapproved[page.name][sender] == true then
        assert(pages[page.name], "Page could not be found with name: "..page.name);
        pages[page.name].data=page.data;
        if Hack.EditedPage() and Hack.EditedPage().name==page.name then
            HackEditBox:SetText(page.data)
        end;
    else
        page.name=Hack.GetUniqueName(page.name);
        local dialog = StaticPopup_Show('HackAccept', sender)
        if dialog then
            dialog.page = page
            dialog.sender = sender
        end
    end;
end;

function Hack.StopSync()
	local menuFrame = CreateFrame('Frame', nil, HackListFrame, 'UIDropDownMenuTemplate')
	local menu = {};
	local pageName = Hack.EditedPage().name;
	if autoapproved[pageName] then
		for name, s in pairs(autoapproved[pageName]) do
			if s == true then
				table.insert(menu, {
					text = "Source: " .. name,
					func = Seal(function(name)
						autoapproved[pageName][name] = nil;
						printf("No longer receiving syncs of page '%s' from %s.", pageName, name);
					end, name)
				});
			end;
		end;
	end;
	if sharing[pageName] then
		for name, s in pairs(sharing[pageName]) do
			if s == SYNC_ACCEPTED then
				table.insert(menu, {
					text = "Target: " .. name,
					func = Seal(function(name)
						sharing[pageName][name] = nil;
						printf("No longer sending syncs of page '%s' to %s.", pageName, name);
					end, name)
				});
			end;
		end;
	end;
	if #menu == 0 then
		table.insert(menu, {
			text = "Not shared with anyone",
			disabled = true
		});
	end;
	EasyMenu(menu, menuFrame, 'cursor', nil, nil, 'MENU')
end

function Hack.Sync()
	local target,realm = UnitName("target");
	if not target then
		StaticPopup_Show('HackNoTargetForSharing');
		return;
	end;
	if not realm then
		realm = select(2, UnitFullName("player"));
	end;
	target = target .. "-" .. realm;
	local pageName = Hack.EditedPage().name;
	if not sharing[pageName] then
		sharing[pageName] = {};
	end;
	sharing[pageName][target] = SYNC_ACCEPTING;
    Remote:Send("Hack", target, "Sync"..Hack.EditedPage().name);
end;

function Hack.AutoApproveUpdates(page, sender)
    autoapproved[page]=autoapproved[page] or {};
    autoapproved[page][sender]=true;
end;

-- add/remove frame from UISpecialFrames (borrowed from TinyPad)
function Hack.MakeESCable(frame,enable)
    local index
    for i=1,#UISpecialFrames do
        if UISpecialFrames[i]==frame then
            index = i
            break
        end
    end
    if index and not enable then
        table.remove(UISpecialFrames,index)
    elseif not index and enable then
        table.insert(UISpecialFrames,1,frame)
    end
end

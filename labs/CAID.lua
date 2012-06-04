Labs = Labs or {};

function Labs.CAID()
	-- settings
	if UnitClass("player") ~= "Mage" then return end


	enableGCD = true
	enableCast = true

	width = 80
	height = 55
	gridGapV = 5
	gridGapH = 5
	blendType = "BLEND"
	bgColor = Media.color(0.1);
	borderColor = "purple";
	gcdbarColor = "violet";

	----
	----
	----
	local gcd = 61304
	local caid = CreateFrame("Frame",nil,UIParent)
	caid:SetFrameStrata("LOW")
	Anchors.Center(caid, 300, -100);
	Frames.Size(caid,width, height)

	Frames.Backdrop(caid, 2);
	Frames.Color(caid, bgColor);
	Frames.BorderColor(caid, borderColor);

	if enableGCD then
	   caid.gcdbar = CreateFrame("Frame",nil,caid)
	   Anchors.ShareHorizontals(caid.gcdbar);
	   caid.gcdbar:SetFrameLevel(caid:GetFrameLevel()+5)
	   caid.gcdbar:SetHeight(2);
	   Frames.Color(caid.gcdbar, borderColor);

	   local start, dur, perc
	   Timing.Every(0.01, function()
		 local height = Frames.Height(caid);
		 start,dur = GetSpellCooldown(gcd)
		 caid.gcdbar:Hide()
		 if start ~= 0 then
		    perc = (GetTime() - start) / dur
		    if perc < 1 then
		       caid.gcdbar:Show()
			   Anchors.Share(caid.gcdbar, "bottom", 0, height*perc);
		    end
		 end
		 
	   end)
	end

	local scd = function(frame,start,duration)
	   if start == 0 then
	      frame.onTrueCooldown = false
	   elseif start ~= GetSpellCooldown(gcd) then
	      frame.onTrueCooldown = true
	   end
	   if frame.onTrueCooldown then
	      local perc = (GetTime() - start) / duration
	      frame.bar:SetWidth(frame:GetWidth()*perc)
	   end
	end

	local CreateCooldownBar = function(spell)
	   local cd = CreateFrame("Frame", nil, CAID)
	   cd:SetFrameLevel(caid:GetFrameLevel()+4)
	   cd.spell = spell
	   cd.bar = cd:CreateTexture(nil,"artwork")
	   cd.bar:SetTexture("Interface\\Buttons\\WHITE8X8")
	   cd.bar:SetBlendMode(blendType)
	   cd.bar:SetPoint("Left")
	   cd.onTrueCooldown = false
	   cd.SetCooldown = scd
	   return cd
	end

	local CoC = CreateCooldownBar("Cone of Cold")
	CoC.bar:SetVertexColor(0,0,1,1)
	local FN = CreateCooldownBar("Frost Nova")
	FN.bar:SetVertexColor(0,0,1,1)
	local BW = CreateCooldownBar("Frost Nova")
	BW.bar:SetVertexColor(1,0,0,1)
	local DB = CreateCooldownBar("Frost Nova")
	DB.bar:SetVertexColor(1,0,0,1)
	local B = CreateCooldownBar("Blink")
	B.bar:SetVertexColor(1,0,1,1)
	local CS = CreateCooldownBar("Counterspell")
	CS.bar:SetVertexColor(1,0,1,1)


	-- autoadjust the bars inside the main frame
	-- put false if you want a nonexistent bar
	-- otherwise the other bar will expand into that space
	local cdgrid = {
	   { CoC, FN },
	   { DB , BW },
	   { B  , CS }
	}

	local h = caid:GetHeight() - (gridGapV*(#cdgrid+1))
	h = h/#cdgrid
	local w

	for k,v in ipairs(cdgrid) do
	   w = caid:GetWidth() - (gridGapH*(#v+1))
	   w = w/#v
	   for l,u in ipairs(v) do
	      if u then
		 u:SetSize(w,h)
		 u:SetPoint(
		    "TopLeft",caid,"TopLeft",
		    gridGapH*l+w*(l-1), -(gridGapV*k+h*(k-1))
		 )
		 u.bar:SetSize(w,h)
	      end
	   end
	end

	Timing.Every(0.05, function()
	      for k,v in ipairs(cdgrid) do
		 for l,u in ipairs(v) do
		    cd = 0
		    if u then
		       
		       u:SetCooldown(GetSpellCooldown(u.spell))
		       if u.onTrueCooldown then
		          u.bar:SetAlpha(0.5)
		       else
		          u.bar:SetAlpha(1)
		       end
		    end
		 end
	      end
	end)
end;

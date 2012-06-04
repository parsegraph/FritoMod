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
	bgColor = {0.1,0.1,0.1,1}
	borderColor = {0.5,0,1,1}
	gcdbarColor = {0.5,0,1,1}

	----
	----
	----
	local gcd = 61304
	local caid = CreateFrame("Frame","CAID",UIParent)
	caid:SetFrameStrata("LOW")
	caid:SetPoint("Center",UIParent,"Center",0,-100)
	Frames.Size(caid,width, height)

	caid.background = caid:CreateTexture(nil,"BACKGROUND")
	caid.background:SetAllPoints(caid)
	caid.background:SetTexture("Interface\\Buttons\\WHITE8X8")
	caid.background:SetBlendMode(blendType)
	caid.background:SetVertexColor(unpack(bgColor))

	caid:SetBackdropColor( unpack(bgColor) )
	caid:SetBackdropBorderColor( unpack(borderColor) )


	local CreateBorderTexture = function()
	   local b = caid:CreateTexture(nil, "border")
	   b:SetBlendMode(blendType)
	   b:SetTexture(unpack(borderColor))
	   return b
	end

	caid.topbar = CreateBorderTexture()
	caid.topbar:SetSize(width,2)
	caid.topbar:SetPoint("Top")

	caid.bottombar = CreateBorderTexture()
	caid.bottombar:SetSize(width,2)
	caid.bottombar:SetPoint("Bottom")

	caid.leftbar = CreateBorderTexture()
	caid.leftbar:SetSize(2,height)
	caid.leftbar:SetPoint("Left")

	caid.rightbar = CreateBorderTexture()
	caid.rightbar:SetSize(2,height)
	caid.rightbar:SetPoint("Right")

	if enableGCD then
	   caid.gcdbar = CreateFrame("Frame",nil,caid)
	   caid.gcdbar:SetSize(width,2)
	   caid.gcdbar:SetFrameLevel(caid:GetFrameLevel()+5)
	   caid.gcdbar.texture = caid.gcdbar:CreateTexture(nil, "background")
	   caid.gcdbar.texture:SetAllPoints(caid.gcdbar)
	   caid.gcdbar.texture:SetBlendMode(blendType)
	   caid.gcdbar.texture:SetTexture(unpack(borderColor))
	   local start, dur, perc
	   Timing.Every(0.01, function() 
		 start,dur = GetSpellCooldown(gcd)
		 caid.gcdbar:Hide()
		 if start ~= 0 then
		    perc = (GetTime() - start) / dur
		    if perc < 1 then
		       caid.gcdbar:Show()
		       caid.gcdbar:SetPoint("Bottom",caid,"Bottom",0,height*perc)
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

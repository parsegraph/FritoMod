-- A collection of button textures, used with Frames.ButtonTexture.
--
-- Each value is a table containing textures to map a Button or CheckButton.
--
-- Ideally, virtual frames would make this sort of thing obsolete. Most of 
-- this code is actually from virtual frames. However, Blizzard's virtual
-- frames usually carry a lot of unwanted baggage that we'd have to prune.
-- We also can't use virtual frames if our frame already exists. These two
-- problems necessitate some sort of Lua-based solution.
--
-- A conservative approach would be to work around the limitations. We'd provide
-- a factory for the virtual frames we want, with extra code to remove unwanted
-- baggage. This seems to only get us really weak code: we're still heavily
-- dependent on Blizzard's virtual frames. I also think the direction this
-- approach takes us is poor: we're not really writing anything powerful, just
-- "fixing bugs."
--
-- A pure approach would be to do nothing. Anything we write that uses virtual 
-- frames will be competing with them. Our solution would be to basically say
-- "Write and use XML when you want to create complicated UIs." Since creating
-- complicated UIs is one of the biggest reasons for creating FritoMod, this
-- simply won't do.
--
-- I chose the bold approach. We steal the useful stuff that Blizzard gave us,
-- but we rewrite it in Lua. We get maximum power and flexibility, since it's
-- entirely our stuff. It also becomes natural to build complicate UIs, since
-- we can design our API to fit well with FritoMod.
--
-- In practice, the redundancy factor hasn't really been a problem. We usually
-- steal good ideas and fit them so FritoMod can do them easily. In other words,
-- we're learning from Blizzard's code and integrating it, rather than merely
-- copying it.
--
-- Of course, you can mix virtual frames with FritoMod all you want. I do this
-- when a virtual frame actually fits well with what I'm doing. However, this 
-- happens less often than you'd think.
if nil ~= require then
    require "Media";
end;

local buttons={};

local function BlendHighlights(button)
    if button.GetHighlightTexture then
        button:GetHighlightTexture():SetBlendMode("ADD");
    end;
    if button.GetCheckedTexture then
        button:GetCheckedTexture():SetBlendMode("ADD");
    end;
end;

buttons.check={
    normal         ="Interface\\Buttons\\UI-CheckBox-Up",
    pushed         ="Interface\\Buttons\\UI-CheckBox-Down",
    highlight      ="Interface\\Buttons\\UI-CheckBox-Highlight",
    checked        ="Interface\\Buttons\\UI-CheckBox-Check",
    disabledChecked="Interface\\Buttons\\UI-CheckBox-Check-Disabled",
    Finish         =BlendHighlights
};

buttons.slot={
    normal         ="Interface\\Buttons\\UI-Quickslot2",
    pushed         ="Interface\\Buttons\\UI-Quickslot-Depress",
    highlight      ="Interface\\Buttons\\ButtonHilight-Square",
    checked        ="Interface\\Buttons\\CheckButtonHilight",
    Finish         =function(button)
        if button.GetNormalTexture then
            local t=button:GetNormalTexture();
            -- Blizzard's code seems to assume we'll never resize this frame
            -- beyond 36 pixels. Resizing seems like something we should
            -- anticipate, so I changed it to use texcoords. These values
            -- are just what looked best to me at the time.
            --
            -- I added the shared anchors to oversize our normal texture. This
            -- emphasizes the "pressed" nature when we click on a button. These
            -- are hardcoded, so they won't scale, but I think that's acceptable;
            -- once a button gets really big, it looks a little odd if it shrinks
            -- dramatically on click.
            t:SetTexCoord(.18,.82,.18,.82);
            Anchors.Share(t, button, "topleft", -2);
            Anchors.Share(t, button, "bottomright", -2);
        end;
        BlendHighlights(button);
    end
};
buttons.default=buttons.slot;

Media.button(buttons);
Media.SetAlias("button", "buttons", "buttontexture");

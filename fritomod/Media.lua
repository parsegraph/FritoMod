-- Media is a common area for providing sources of media, like fonts, textures,
-- colors, and so forth. It's similar to LibSharedMedia and other mods, though
-- it does not pretend to be the sole provider of media. It also doesn't require
-- you to learn a custom API for accessing tabular data. For these reasons, I
-- prefer ours over object-based or global registry-based solutions.
--
-- However, like I said, other providers are happily welcome in this mod, and we
-- steal their data freely. Here's how you use Media:
--
-- local t=UIParent:CreateTexture();
-- t:SetTexture(unpack(Media.colors.red));
--
-- That's it. We support any capitalization (similar to our mod's Chat table), so
-- you don't need to remember this piece of information, nor do you need to check
-- before using other tables.
--
-- If you're writing a provider, try to be as forgiving as possible. Have a sensible
-- or obvious default value, and anticipate and correct common user errors, such as
-- misspellings or locale-dependent spellings. Media is intended to be extremely
-- easy to use.
--
-- You register your provider by setting it for the correct media name. For example,
-- if I want to support LibSharedMedia, this is how I would do it:
--
--  Media.color(function(name)
--      if not LibStub then
--          return;
--      end;
--      local sharedMedia = LibStub("LibSharedMedia-3.0");
--      if not sharedMedia then
--          return;
--      end;
--      return sharedMedia:Fetch("color", name);
--  end);
--
-- As you can see, most of our code is ensuring we actually have SharedMedia. Once this
-- is executed, we'll have full access to any color in SharedMedia. Note that for this
-- particular example, we provide this code for you. Use it through:
--
-- Media.color(Curry(Media.SharedMedia, "color"));
--
-- I'm not sure whether older registries should have higher priority or not. I think
-- the code prefers this, but it's not set in stone just yet. If you need to register
-- a provider out of order, do so by accessing Media's registry directly, like so:
--
-- table.insert(Media.registry.color, 1, yourProvider);
--
-- As always, please access this internal with care.


local registry={};
Media = setmetatable({
    registry=registry,
    SharedMedia=function(mediaType, mediaName)
        if not LibStub then
            return;
        end;
        local sharedMedia = LibStub("LibSharedMedia-3.0");
        if not sharedMedia then
            return;
        end;
        return sharedMedia:Fetch("color", name);
    end
    }, {
    __newindex=function(self,k,v)
        error("Media is not directly settable: use Media['"..k.."'](v) instead");
    end;
    __index=function(self,mediaType)
        if type(mediaType) == "string" then
            mediaType=mediaType:lower();
        end;
        if not registry[mediaType] then
            rawset(self,mediaType, setmetatable({}, {
                __call=function(self, provider)
                    assert(provider, "provider must not be nil");
                    if not registry[mediaType] then
                        registry[mediaType] = {};
                    end;
                    table.insert(registry[mediaType], provider);
                    return provider;
                end,
                __index=function(self, k)
                    if type(k) == "string" then
                        k=k:lower();
                    end;
                    local reg=registry[mediaType];
                    if reg==nil then
                        return nil;
                    end;
                    for i=1, #reg do
                        local provider=reg[i];
                        local v;
                        if type(provider) == "function" then
                            v=provider(k);
                        elseif type(provider) == "table" then
                            v=provider[k];
                        end;
                        if v ~= nil then
                            return v;
                        end;
                    end;
                    if k ~= "default" then
                        return self.default
                    end;
                end,
                __newindex=function(self)
                    error(mediaType.." table is not directly editable");
                end
            }));
        end;
        return self[mediaType];
    end
});

rawset(Media, "SetAlias", function(root, ...)
    for i=1,select("#", ...) do
        rawset(Media, select(i, ...), Media[root]);
    end;
end);

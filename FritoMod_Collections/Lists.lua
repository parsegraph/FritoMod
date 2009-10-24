Lists = {}; 
local Lists = Lists;

-- Mixes in iteration functionality for lists.
Mixins.Iteration(Lists, ipairs);
Metatables.Defensive(Lists);

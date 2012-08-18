if nil ~= require then
    require "fritomod/Callbacks-Frames";
    require "fritomod/currying";
end;

Callbacks = Callbacks or {};

Callbacks.OnEscape = Headless(Callbacks.SimpleEvent, "OnEscapePressed");
Callbacks.OnEscapePressed = Callbacks.OnEscape;

Callbacks.OnEnter = Headless(Callbacks.SimpleEvent, "OnEnterPressed");
Callbacks.OnEnterPressed = Callbacks.OnEnter;

Callbacks.OnTextChanged = Headless(Callbacks.SimpleEvent, "OnTextChanged");
Callbacks.OnTextChange = Callbacks.OnTextChanged;

Callbacks.OnTab = Headless(Callbacks.SimpleEvent, "OnTabPressed");
Callbacks.OnTabPressed = Callbacks.OnTab;

Callbacks.OnSpace = Headless(Callbacks.SimpleEvent, "OnSpacePressed");
Callbacks.OnSpacePressed = Callbacks.OnSpace;

-- vim: set et :

if nil ~= require then
    require "FritoMod_Functional/currying";

    require "FritoMod_OOP/OOP/Class";

    require "FritoMod_States/States";
end;

StateMachine = OOP.Class();
local StateMachine = StateMachine;

function StateMachine:Constructor(schema, context)
    States.StateContext(schema, self);
    assert(context, "context is falsy");
    self.Feed = Curry(self, self.Feed, context);
end;

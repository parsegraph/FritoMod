StateMachine = OOP.Class();
local StateMachine = StateMachine;

function StateMachine:Constructor(schema, context)
    States.StateContext(schema, self);
    assert(context, "context is falsy");
    self.Feed = Curry(self, self.Feed, context);
end;

-- Parameters are higher-order functions that behave similar to curried functions. The difference is that
-- while currying attaches constant references or values, parametrics defer to functions.
--
-- While I liked the idea of parameters, these haven't lived up to their purpose yet. The examples that I 
-- came up with to demonstrate them ended up being more confusing than their primitive-only equivalents.
--
-- For example, here's an example of the Fibonacci sequence, using parametrics:
-- local t={0,1};
-- local fib=Functions.HookReturn(
--     Parameters.Unpacked(Operators.Add, t),
--     function(v)
--         table.insert(t, v);
--         return table.remove(t, 1);
--     end
-- );
--
-- And here's the primitive approach:
--
-- local a,b=0,1;
-- local fib=function()
--     local rv,sum=a,a+b;
--     a,b=b,sum;
--     return rv;
-- end;
--
-- While the former seems more "precise", the latter makes a whole lot more sense. I'm going to leave this
-- code in, since I think there's some potential value. However, I haven't found it yet.

if nil ~= require then
    require "fritomod/currying";
    require "fritomod/Functions";
end;

Parameters=Parameters or {};

function Parameters.Function(fxn, generator, ...)
    generator=Curry(generator, ...);
    return function(...)
        return fxn(generator(), ...);
    end;
end;

function Parameters.ReturnValue(f, ...)
   f=Curry(f, ...);
   local rv=Objects.Value();
   return Parameters.Function(Functions.ReturnSpy(f, rv.Set), rv.Get);
end;

function Parameters.Unpacked(func, t)
   return function(...)
      return func(UnpackAll(t, {...}));
   end;
end;
Parameters.Table=Parameters.Unpacked;


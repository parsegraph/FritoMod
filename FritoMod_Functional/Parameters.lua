-- Parameters are higher-order functions that behave similar to curried functions. The difference is that
-- while currying attaches constant references or values, parametrics defer to functions. These parametric
-- functions are succinct building blocks for complicated procedures.
--
-- For example, here's an example of the Fibonacci sequence, using parametrics:
-- local t={0,1};
-- local fib=Functions.HookReturn(
--    Parameters.Unpacked(Operators.Add, t),
--    Curry(Lists.ShiftTrim, t, 2)
-- );
-- for i=1,5 do print(fib()) end;
--
-- I've found that for most problems, I'm using a combination of a few different tools to achieve my
-- result. This case was no different. I feel like the above example is a good back-of-the-book solution;
-- namely, it demonstrates the utility of this mod, but in practice, I might inline some of these functions.
--
-- Don't be afraid to use primitives or regular functions. If your solution works for you, go with it. There's
-- no rule that you should prefer this mod's tools over others, or over your own work. Many of the functions
-- that exist here are due to writing a problem in a naive fashion, then refactoring until the decomposition
-- works for me.
--
-- Parametrics are somewhat unique to this mod, which is heavily biased towards a functional approach to
-- problems. They may appear confusing, not unlike how currying appears confusing at first glance. I found
-- their expressiveness to be an asset. They let me assemble different kinds of processes very quickly. They
-- also greatly increase reuse and refactor potential, since they decompose problems along functional, rather
-- than object-oriented boundaries.
--
-- It should be noted that parametrics are not designed with efficiency as a primary goal. If you have performance
-- intensive code, inlining your functions may help. "Measure, refactor, repeat" is my recommended approach here.

if nil ~= require then
    require "FritoMod_Functional/currying";
    require "FritoMod_Functional/Functions";
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


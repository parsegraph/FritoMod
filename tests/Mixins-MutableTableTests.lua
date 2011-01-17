if nil ~= require then
    require "Assert";
    require "Tests";
end;

Mixins=Mixins or {};

function Mixins.MutableTableTests(Suite, library)
	Assert.Type("table", library, "Library must be a table");

	function Suite:TestSet()
        local t = Suite:Table({
			a=2
		});
		library.Set(t, "a", 3);
		Assert.Equals(3, library.Get(t, "a"));
	end;

    function Suite:TestChange()
        local t=Suite:Table({a=42});
        local r=library.Change(t, "a", 99);
        Assert.Equals(Suite:Table({a=99}), t);
        r();
        Assert.Equals(Suite:Table({a=42}), t);
    end;

    function Suite:TestDelete()
        local iterable = Suite:Table({
			a=2,
			b=3
		});
        local v = library.Delete(iterable, "a");
		Assert.Equals(2, v);
        Assert.Equals(1, library.Size(iterable), "Iterable's size decreases after removal");
    end;

    function Suite:TestClear()
        local iterable = Suite:Table({
			a=2,
			b=3,
			c=4
		});
        library.Clear(iterable);
        assert(library.IsEmpty(iterable), "Iterable is empty");
        assert(library.Equals(iterable, Suite:Table()), "Iterable is equal to an empty iterable");
    end;

	return Suite;
end;

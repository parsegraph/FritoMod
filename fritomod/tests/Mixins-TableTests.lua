if nil ~= require then
	require "fritomod/Assert";
	require "fritomod/Tests";
end;

Mixins=Mixins or {};

function Mixins.TableTests(Suite, library)
	assert(not rawget(Suite, "Array"), "TableTests is not compatible with ArrayTests");

	function Suite:TestSuiteHasTable()
		Assert.Type("function", Suite.Table, "Suite has an 'Table' function");
		assert(Suite:Table({a=1,b=2,c=3}), "Table returns a truthy value");
		assert(Suite:Table(), "Table handles empty arguments");
		assert(Suite:Table() ~= Suite:Table(), "Table test suite must return unique iterables");
	end;

	function Suite:TableCreator(t)
		return Curry(Suite, "Table", t);
	end;

	function Suite:TestEquals()
		assert(library.Equals(Suite:Table(), Suite:Table()),
			"Equals returns true for empty tables");
		assert(library.Equals(Suite:Table({a=1}), Suite:Table({a=1})),
			"Equals returns true for equal tables");
		assert(not library.Equals(Suite:Table({a=1}), Suite:Table({a=2})),
			"Equals returns false for unequal values");
		assert(not library.Equals(Suite:Table({a=1}), Suite:Table({b=1})),
			"Equals returns false for unequal keys");
		assert(not library.Equals(Suite:Table({a=1}), Suite:Table({a=1, b=1})),
			"Equals returns false for unequal subset");
	end;

	function Suite:TestAssertEquals()
		local a=Suite:TableCreator({a=1,b=2});
		local b=Suite:TableCreator({a=1,b=2});
		library.AssertEqual(a(),b());
		Assert.Exception(library.AssertEqual, a(), Suite:Table({a=1}));
		Assert.Exception(library.AssertEqual, a(), Suite:Table({a=1,b=2,c=3}));
		Assert.Exception(library.AssertEqual, Suite:Table({a=1,b=2,c=3}), a());
		Assert.Exception(library.AssertEqual, Suite:Table({a=1}), a());
	end;

	function Suite:TestSize()
		Assert.Equals(0, library.Size(Suite:Table()), "Size reports zero for empty table");
		Assert.Equals(3, library.Size(Suite:Table({
			a=1,
			b=2,
			c=3
		})), "Size reports three for three-element table");
		Assert.Equals(1, library.Size(Suite:Table({[false]=false})),
			"Size reports one for iterable with one false pair");
	end;

	function Suite:TestIsEmpty()
		assert(library.IsEmpty(Suite:Table()), "IsEmpty returns true for empty iterable");
		assert(not library.IsEmpty(Suite:Table({a=1})), "IsEmpty returns false for non-empty iterable");
		assert(not library.IsEmpty(Suite:Table({[false]=false})),
			"IsEmpty returns false for an iterable with falsy pairs");
	end;

	function Suite:TestContainsKey()
		local tc = Curry(Suite, "Table", {a=true,c=false,[false]=false});
		assert(library.ContainsKey(tc(), "a"), "ContainsKey finds a contained key");
		assert(not library.ContainsKey(tc(), "b"), "ContainsKey does not find a missing key");
		assert(library.ContainsKey(tc(), "c"), "ContainsKey finds a key with a falsy value");
		assert(library.ContainsKey(tc(), false), "ContainsKey finds a falsy key");
		assert(not library.ContainsKey(tc(), nil), "ContainsKey doesn't find nil, but doesn't throw");
	end;

	function Suite:TestKeyIterator()
		local ref = {
			a=1,
			b=2,
			c=3
		};
		local c={};
		local choke=Tests.Choke(3);
		for k in library.KeyIterator(Suite:Table(ref)) do
			choke();
			assert(c[k] == nil, "Key must not be iterated twice");
			c[k]=ref[k];
		end;
		Assert.Equals(ref, c, "Iteration yields equal tables");
	end;

	function Suite:TestKeyIteratorHasStableKeyOrder()
		local ref = {
			a=1,
			b=2,
			c=3
		};
		local keys={};
		local choke=Tests.Choke(3);
		for k in library.KeyIterator(Suite:Table(ref)) do
			choke();
			table.insert(keys, k);
		end;
		local c={};
		choke=Tests.Choke(3);
		for k in library.KeyIterator(Suite:Table(ref)) do
			choke();
			table.insert(c, k);
		end;
		Assert.Equals(keys, c);
	end;

	function Suite:TestKeyIteratorHandlesFalsyKey()
		local i=library.KeyIterator(Suite:Table({
			[false]=false
		}));
		Assert.Equals(false, i());
	end;

	function Suite:TestKeyIteratorHandlesEmptyIterable()
		i = library.KeyIterator(Suite:Table());
		Assert.Equals(nil, i(), "Iterator returns nil for empty table");
	end;

	function Suite:TestValueIterator()
		local i = library.ValueIterator(Suite:Table({[1]="a",[2]="b"}));

        local values = {};
        while true do
            local v = i();
            if not v then
                break;
            end;
            values[v] = true;
        end;
		Assert.Equals({a=true,b=true}, values, "Iterator returns all keys");
		Assert.Equals(nil, i(), "Iterator returns nil beyond last key");
		Assert.Equals(nil, i(), "Iterator is idempotent");
	end;

	function Suite:TestValueIteratorHandlesRepeatedElements()
		local i = library.ValueIterator(Suite:Table({a=true, b=true}));
		Assert.Equals(true, i(), "Iterator finds first element");
		Assert.Equals(true, i(), "Iterator finds second, repeated element");
		Assert.Equals(nil, i(), "Iterator returns nil beyond last key");
	end;

	function Suite:TestValueIteratorHandlesRepeatedElements()
		local i = library.ValueIterator(Suite:Table({a=true, b=true}));
		Assert.Equals(true, i(), "Iterator finds first element");
		Assert.Equals(true, i(), "Iterator finds second, repeated element");
		Assert.Equals(nil, i(), "Iterator returns nil beyond last key");
	end;

	function Suite:TestValueIteratorHandlesEmptyIterable()
		local i = library.ValueIterator(Suite:Table());
		Assert.Equals(nil, i(), "Iterator returns nil for empty table");
	end;

	function Suite:TestBidiIteratorBehavesLikeIterator()
		local tc = Curry(Suite, "Table", {
			a=2,
			b=3,
			c=4
		});
		local choke=Tests.Choke(4);
		local bi = library.BidiKeyIterator(tc());
		local i = library.KeyIterator(tc());
		while true do
			choke();
			local v=i();
			local biv=bi();
			Assert.Equals(v, biv);
			if v == nil then
				break;
			end;
		end;
	end;

	function Suite:TestBidiIteratorCanGoBackwards()
		local t = Suite:Table({
			a=2,
			b=3,
			c=4
		});
		local i = library.BidiKeyIterator(t);
		local keys={};
		table.insert(keys, i());
		table.insert(keys, i());
		Assert.Equals(keys[1], i:Previous());
	end;

	function Suite:TestBidiIteratorIsSafeOnBadPrevious()
		local t=Suite:Table({
			a=2
		});
		local i=library.BidiKeyIterator(t);
		Assert.Equals(nil, i:Previous());
	end;

	function Suite:TestBidiIteratorIsSafeOnBadPrevious()
		local t=Suite:Table({
			a=2
		});
		local i=library.BidiKeyIterator(t);
		Assert.Equals(nil, i:Previous());
	end;

	function Suite:TestBidiIteratorIgnoresRedundantNextCalls()
		local t=Suite:Table({
			a=2
		});
		local i=library.BidiKeyIterator(t);
		Assert.Equals("a", i());
		Assert.Equals(nil, i());
		Assert.Equals(nil, i(), "BidiIterator is idempotent");
		Assert.Equals("a", i:Previous(), "BidiIterator ignores redundant calls and keeps it place");
	end;

	function Suite:TestBidiIteratorIgnoresRedundantPreviousCalls()
		local t=Suite:Table({
			a=2
		});
		local i=library.BidiKeyIterator(t);
		Assert.Equals(nil, i:Previous());
		Assert.Equals(nil, i:Previous(), "BidiIterator is idempotent");
		Assert.Equals("a", i(), "BidiIterator ignores redundant calls and keeps it place");
	end;

	function Suite:TestFilterReturnsASubset()
		local t=Suite:Table({
			a=true,
			b=true,
			c=true,
			d=true
		});
        Assert.Equals({c=true,d=true}, library.FilterKeys(t, function(v)
			return v > "b";
		end));
	end;

    function Suite:TestSortedIteratorWithTable()
		if not library.SupportsGet() then
			return;
		end;
		local list = Suite:Table({
            b = 2,
            c = 3,
            a = 1
        });
		local iter = library.ValueSortedIterator(list);
		local results = {};
		for k, v in iter do
			table.insert(results, k);
		end;
		Assert.Equals({"a", "b", "c"}, results);
    end;

	return Suite;
end;

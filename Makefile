all: test files.xml tests/files.xml wow/files.xml wow/tests/files.xml labs/files.xml
.PHONY: all

test:
	find tests wow/tests wow/api/tests -name '*.lua' -print0 | xargs -0 ./run-test
.PHONY: test

clean:
	rm -f files.xml tests/files.xml wow/files.xml wow/tests/files.xml labs/files.xml
.PHONY: clean

files.xml: *.lua
	./update $@

tests/files.xml: tests/*.lua
	./update $@

wow/files.xml: wow/*.lua
	./update $@

wow/tests/files.xml: wow/*.lua
	./update $@

labs/files.xml: labs/*.lua
	./update $@

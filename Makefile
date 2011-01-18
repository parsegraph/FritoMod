all: test files.xml tests/files.xml wow/files.xml wow/tests/files.xml labs/files.xml
.PHONY: all

test:
	find tests wow/tests wow/api/tests -name '*.lua' -print0 | xargs -0 ./run-test
.PHONY: test

files.xml: *.lua
	./update

tests/files.xml: tests/*.lua
	./update tests

wow/files.xml: wow/*.lua
	./update wow

wow/tests/files.xml: wow/*.lua
	./update wow_tests

labs/files.xml: labs/*.lua
	./update labs

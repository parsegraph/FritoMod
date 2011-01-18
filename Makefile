manifests=files.xml tests/files.xml wow/files.xml wow/tests/files.xml labs/files.xml libs/files.xml

all: test $(manifests)
.PHONY: all

test:
	find tests wow/tests wow/api/tests -name '*.lua' -print0 | xargs -0 ./run-test
.PHONY: test

clean:
	rm -f $(manifests)
.PHONY: clean

$(manifests):
	./update $@

files.xml: *.lua
tests/files.xml: tests/*.lua
wow/files.xml: wow/*.lua
wow/tests/files.xml: wow/*.lua
labs/files.xml: labs/*.lua
libs/files.xml: libs/*.lua

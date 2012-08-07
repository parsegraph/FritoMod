dirs = fritomod labs deps
ifndef NO_TEST
dirs += fritomod/tests labs/tests
endif

all: toc
.PHONY: all

test:
	./bin/run-test.sh
.PHONY: test

toc: FritoMod.toc files.xml
.PHONY: toc

FritoMod.toc: $(dirs) FritoMod.toc.in
	./FritoMod.toc.in >.FritoMod.toc
	mv .FritoMod.toc FritoMod.toc

files.xml: bin/get-requires
	./bin/get-requires --windows --xml $(dirs) >.files.xml
	mv .files.xml files.xml

clean:
	rm -f FritoMod.toc .FritoMod.toc
	rm -f files.xml .files.xml
.PHONY: clean


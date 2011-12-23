dirs = fritomod fritomod/labs deps
ifndef NO_TEST
dirs += fritomod/tests
endif

all: toc
.PHONY: all

test:
	./bin/run-test.sh
.PHONY: test

toc: FritoMod.toc
.PHONY: toc

FritoMod.toc: $(dirs) bin/get-requires FritoMod.toc.in
	./FritoMod.toc.in >.FritoMod.toc
	./bin/get-requires $(dirs) >>.FritoMod.toc
	mv .FritoMod.toc FritoMod.toc

clean:
	rm -f FritoMod.toc .FritoMod.toc
.PHONY: clean


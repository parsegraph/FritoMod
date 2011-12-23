dirs = fritomod fritomod/labs deps
ifndef NO_TEST
dirs += fritomod/tests
endif

all: toc
.PHONY: all

test:
	find -name '*.lua' ! -path './.git/*' -print0 | xargs -0 ./bin/run-test
.PHONY: test

toc: FritoMod.toc
.PHONY: toc

FritoMod.toc:
	./FritoMod.toc.in >FritoMod.toc
	./bin/get-requires $(dirs) >>FritoMod.toc

clean: 
	rm -f FritoMod.toc
.PHONY: clean


dirs = . labs libs
ifndef NO_TEST
dirs += tests
endif

all: test toc
.PHONY: all

test:
	find -name '*.lua' ! -path './.git/*' -print0 | xargs -0 ./bin/run-test
.PHONY: test

toc: FritoMod.toc
.PHONY: toc

FritoMod.toc:
	./FritoMod.toc.in >FritoMod.toc
	./get-requires $(dirs) >>FritoMod.toc

clean: 
	rm -f FritoMod.toc
.PHONY: clean


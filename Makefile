dirs = fritomod labs deps hack
ifndef NO_TEST
dirs += fritomod/tests labs/tests hack/tests
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

files.xml: $(dirs) bin/get-requires
	./bin/get-requires --windows --xml $(dirs) >.files.xml
	mv .files.xml files.xml

prefix=/usr/local
datadir=$(prefix)/share
luadir=$(datadir)/lua/5.1

install: $(addprefix $(DESTDIR)/$(luadir)/, fritomod wow)

$(DESTDIR)/$(luadir)/fritomod: fritomod
	mkdir -p $@
	cp $^/*.lua $@

$(DESTDIR)/$(luadir)/wow: wow
	mkdir -p $@/api
	cp $^/*.lua $^/api/*.lua $@

uninstall:
	rm -rf $(DESTDIR)/$(luadir)/fritomod
	rm -rf $(DESTDIR)/$(luadir)/wow

clean:
	rm -f FritoMod.toc .FritoMod.toc
	rm -f files.xml .files.xml
.PHONY: clean

count:
	find -name '*.lua' -print0 | xargs -0 wc -l | tail -1

dirs = . tests wow wow/tests labs libs
manifests = $(addsuffix /files.xml, $(dirs))

all: xml toc
.PHONY: all

test:
	find -name '*.lua' ! -path './.git/*' -print0 | xargs -0 ./run-test
.PHONY: test

clean: 
	rm -f $(manifests)
	rm -f FritoMod.toc
.PHONY: clean

toc: FritoMod.toc
.PHONY: toc

xml: $(manifests)
.PHONY: xml 

# This convoluted piece of code lets us have each file manifest depend only on
# the *.lua files that are contained within its directory. It also lets us not
# have to specify these prerequisites manually.
#
# There's probably an easier way to do this, but I'm new to make.
.SECONDEXPANSION:
$(manifests): %files.xml: $$(wildcard $$**.lua)
	./update $@

FritoMod.toc: $(manifests)
	./FritoMod.toc.in >FritoMod.toc
	for f in $(manifests); do \
		echo $$f | sed -e 's#^\./##' -e 's#/#\\#g'; \
	done >>FritoMod.toc

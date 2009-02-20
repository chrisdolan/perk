PERL      = perl
PARROTDIR = ../..
PARROT    = $(PARROTDIR)/parrot
MERGEPBC  = $(PARROTDIR)/pbc_merge
PCTDIR    = $(PARROTDIR)/runtime/parrot/library
PCTPBC    = $(PCTDIR)/PCT.pbc
PERL6DIR  = ../rakudo
PERL6PBC  = perl6.pbc
ENV       = env PERL6LIB='./t:./lib:$(PCTDIR)'
PERL6     = $(ENV) $(PARROT) $(PERL6PBC)
CP        = $(PERL) -MExtUtils::Command -e cp

PM	  = $(shell ls lib/Perk/*.pm lib/Perk/*/*.pm)
PIR       = $(PM:.pm=.pir)
PBC       = $(PM:.pm=.pbc) $(T:.t=.pbc)

all:    build
build:	perk.pbc
perk.pir:	$(PIR) perk.pl $(PERL6PBC)
	$(PERL6) --target=pir --output=$@ perk.pl

#perk.pbc:	perk.pir $(PERL6PBC) $(PCTPBC)
#	$(PARROT) -o perk_tmp.pbc perk.pir
#	$(MERGEPBC) -o $@ perk_tmp.pbc $(PERL6PBC) $(PCTPBC)
#	$(RM) perk_tmp.pbc

# Copy perl6.pbc to the local dir because the inc path doesn't seem to work...
$(PERL6PBC):	$(PERL6DIR)/perl6.pbc Makefile
	$(CP) $< $@

test:	build
	$(ENV) $(PERL) t/harness
test-parse:	build
	$(ENV) $(PERL) t/harness --target=parse
test-past:	build
	$(ENV) $(PERL) t/harness --target=past
test-pir:	build
	$(ENV) $(PERL) t/harness --target=pir

clean:
	$(RM) $(PIR) $(PBC) perk.pbc perk.pir perl6.pbc

%.pir:  %.pm $(PERL6PBC)
	$(PERL6) --target=pir --output=$@ $<
%.pbc:  %.pir $(PARROT)
	$(PARROT) -o $@ $<

.PHONY: all check test test-parse test-pir test-past build clean

PARROTDIR = ../..
PARROT    = $(PARROTDIR)/parrot
MERGEPBC  = $(PARROTDIR)/pbc_merge
PCTDIR    = $(PARROTDIR)/runtime/parrot/library
PCTPBC    = $(PCTDIR)/PCT.pbc
PERL6DIR  = ../rakudo
PERL6PBC  = $(PERL6DIR)/perl6.pbc
ENV       = env PERL6LIB='./t:./lib:$(PERL6DIR):$(PCTDIR)'
PERL6     = $(ENV) $(PARROT) $(PERL6PBC)

PM	  = $(shell ls lib/Perk/*.pm lib/Perk/*/*.pm)
PIR       = $(PM:.pm=.pir)
PBC       = $(PM:.pm=.pbc) $(T:.t=.pbc)

all:    build

check:
	@ [ -e $(PARROT) ] || ( echo "Missing $(PARROT)" ; exit 1 )

prebuild:       check $(PIR)

build:	prebuild perk.pbc
perk.pir:	perk.pl
	$(PERL6) --target=pir --output=$@ $<

#perk.pbc:	perk.pir $(PERL6PBC) $(PCTPBC)
#	$(PARROT) -o perk_tmp.pbc perk.pir
#	$(MERGEPBC) -o $@ perk_tmp.pbc $(PERL6PBC) $(PCTPBC)
#	$(RM) perk_tmp.pbc

test:	build
	$(ENV) perl t/harness
test-parse:	build
	$(ENV) perl t/harness --target=parse
test-past:	build
	$(ENV) perl t/harness --target=past
test-pir:	build
	$(ENV) perl t/harness --target=pir

clean:  cleanpir cleanpbc
cleanpir:
	$(RM) $(PIR)
cleanpbc:
	$(RM) $(PBC)

%.pir:  %.pm $(PERL6PBC)
	$(PERL6) --target=pir --output=$@ $<
%.pbc:  %.pir
	$(PARROT) -o $@ $<

.PHONY: all check test test-parse test-pir test-past build prebuild clean cleanpir cleanpbc

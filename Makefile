TARGETS := $(patsubst ./%.fa,current/%.gene_info.RData,$(shell find . -name "*.fa"))

.PHONY: all show-targets

# keep gnu make from deleting intermediate files:
.SECONDARY:

all: $(TARGETS)

show-targets:
	@echo $(TARGETS)

%.rfa: %.gbff
	./gbff2fasta.R $< > $@

current/%.psl: current/refseq/hum.rfa %.fa
	./blat.R $^ $@

current/%.psl.RData: current/%.psl
	./psl2RData.R $< $@

current/%.gene_info.RData: current/%.psl.RData ./bestgene.R
	./bestgene.R $< $@

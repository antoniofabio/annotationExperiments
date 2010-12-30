TARGETS := $(patsubst ./%.fa,current/%.gene_info.RData,$(shell find . -name "*.fa")) \
	$(patsubst %.gbff,%.gene_info.RData,$(shell find current/refseq -name "*.gbff"))

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

current/refseq/%.gene_info.RData: current/refseq/%.gbff gbff2RData.R
	./gbff2RData.R $< $@

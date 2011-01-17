TARGETS := $(patsubst ./%.fa,current/%.gene_info.RData,$(shell find . -name "*.fa")) \
	$(patsubst ./%.fa,current/%.Annot.custom.RData,$(shell find . -name "*.fa")) \
	current/refseq/hum.gene_info.RData
DIRS := $(sort $(dir $(TARGETS)))

.PHONY: all show-targets

# keep gnu make from deleting intermediate files:
.SECONDARY:

all: $(TARGETS)

$(DIRS):
	mkdir -p $(DIRS)

show-targets:
	@echo $(TARGETS)

%.gbff.gz: %.gbff
	gzip $<

%.rfa: %.gbff.gz gbff2fasta.R
	./gbff2fasta.R $< > $@

current/%.psl: current/refseq/hum.rfa %.fa blat.R | $(DIRS)
	./blat.R $(wordlist 1,2,$^) $@

current/%.psl.RData: current/%.psl psl2RData.R
	./psl2RData.R $< $@

current/%.gene_info.RData: current/%.psl.RData bestgene.R
	./bestgene.R $< $@

current/refseq/%.gene_info.tab.gz: current/refseq/%.gbff.gz gbffParser.R
	./gbffParser.R $< | gzip > $@

current/refseq/%.gene_info.RData: current/refseq/%.gene_info.tab.gz gene_info.R
	./gene_info.R $< $@

current/%.Annot.custom.RData: current/%.gene_info.RData current/refseq/hum.gene_info.RData Annot.custom.R
	./Annot.custom.R $(wordlist 1,2,$^) $@

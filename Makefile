AFFY_FASTA_COLON := $(shell find ./affy -name "*.fa.colon")
AFFY := $(shell find ./affy -name "*.fa") $(patsubst ./%.fa.colon,./%.fa,$(AFFY_FASTA_COLON))
AGILENT := $(shell find ./agilent -name "*.fa")
ALL_FASTA := $(AFFY) $(AGILENT)
TARGETS := $(patsubst ./%.fa,current/%.gene_info.RData,$(ALL_FASTA)) \
	$(patsubst ./%.fa,current/%.Annot.custom.RData,$(ALL_FASTA)) \
	$(patsubst ./%.fa,org.Hs.eg/%.Annot.custom.RData,$(ALL_FASTA)) \
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

%.fa: %.fa.colon
	./fastaColon2fastaProper.R $< > $@

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

org.Hs.eg/%.Annot.custom.RData: current/%.gene_info.RData org.Hs.eg/org.Hs.eg.RData Annot.custom.R | $(DIRS)
	./Annot.custom.org.Hs.R $(wordlist 1,2,$^) $@

TARGETS := $(patsubst ./%.fa,current/%.gene_info.RData,$(shell find . -name "*.fa")) \
	current/refseq/hum.gene_info.RData

.PHONY: all show-targets

# keep gnu make from deleting intermediate files:
.SECONDARY:

all: $(TARGETS)

show-targets:
	@echo $(TARGETS)

%.gbff.gz: %.gbff
	gzip $<

%.rfa: %.gbff.gz gbff2fasta.R
	./gbff2fasta.R $< > $@

current/%.psl: current/refseq/hum.rfa %.fa blat.R
	./blat.R $(wordlist 1,2,$^) $@

current/%.psl.RData: current/%.psl psl2RData.R
	./psl2RData.R $< $@

current/%.gene_info.RData: current/%.psl.RData bestgene.R
	./bestgene.R $< $@

current/refseq/%.gene_info.tab.gz: current/refseq/%.gbff.gz gbffParser.R
	./gbffParser.R $< | gzip > $@

current/refseq/%.gene_info.RData: current/refseq/%.gene_info.tab.gz
	Rscript -e 'gene_info <- read.delim("$<", header=TRUE, as.is=TRUE); save(gene_info, file="$@")'
